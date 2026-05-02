"""
    parseXMLToStaysDF(xmlFilePath::String)

Extract stays from an FHIR XML file and return them as a DataFrame.

Columns in the DataFrame are the following:
  - patient_ref
  - firstname
  - lastname
  - birthdate
  - hospitalization_in_time (the overall hospitalisationn in time, which may be different from the unit in time if the patient was transferred from another unit)
  - hospitalization_out_time (the overall hospitalisation out time, which may be different from the unit out time if the patient was transferred to another unit before being discharged)
  - unit_code_name (a short name for the unit, e.g. "ICU", "MED", etc.)
  - unit_name (the full name of the unit, e.g. "Intensive Care Unit", "Medical Ward", etc.)
  - sector (because a unit may be subdivided into sectors)
  - room (the room within the unit)
  - unit_in_time (the time the patient entered the unit)
  - unit_out_time (the time the patient left the unit)
  - patient_died_during_stay: true if the Encounter discharge disposition is "exp" (Expired), false if the encounter is completed without that code, missing if the encounter is still in progress
"""
function ETLCtrl.FHIR.parseXMLToStaysDF(xmlFilePath::String)
    xmlDoc = ETLCtrl.FHIR.loadXMLFile(xmlFilePath)
    root   = EzXML.root(xmlDoc)
    ns     = ["fhir" => "http://hl7.org/fhir"]

    # Helper: return the @value attribute of the first XPath match, or missing
    function attr_val(node, xpath)
        n = EzXML.findfirst(xpath, node, ns)
        isnothing(n) ? missing : n["value"]
    end

    # Helper: extract a FHIR resource id from a reference value.
    # Handles both "ResourceType/id" and "urn:uuid:id" formats.
    ref_id(ref) = replace(ref, r"^urn:uuid:" => "") |> s -> last(split(s, "/"))

    # Helper: parse a date string (yyyy-mm-dd) to Date, or missing
    function parse_date(s)::Union{Date, Missing}
        ismissing(s) && return missing
        Date(s, dateformat"yyyy-mm-dd")
    end

    # Helper: parse a FHIR dateTime string to ZonedDateTime, or missing.
    # Handles full ISO-8601 with offset (e.g. "2022-04-04T10:00:00+02:00")
    # and date-only values (e.g. "2022-05-12") treated as midnight for the hospital timezone.
    function parse_zdt(s)::Union{ZonedDateTime, Missing}
        ismissing(s) && return missing
        # date-only: "yyyy-mm-dd"
        if occursin(r"^\d{4}-\d{2}-\d{2}$", s)
            return ZonedDateTime(
                DateTime(s, dateformat"yyyy-mm-dd"),
                TRAQUERUtil.getTimeZone()
            )
        end
        TRAQUERUtil.convertStringToZonedDateTime(s)
    end

    # ── Patient lookup: FHIR id → (patient_ref, firstname, lastname, birthdate, deceased_dt)
    patients = Dict{String, NamedTuple}()
    for pat in EzXML.findall("//fhir:Patient", root, ns)
        fhir_id = attr_val(pat, "fhir:id")
        ismissing(fhir_id) && continue
        deceased_str = attr_val(pat, "fhir:deceasedDateTime")
        patients[fhir_id] = (
            patient_ref = attr_val(pat, "fhir:identifier/fhir:value"),
            firstname   = attr_val(pat, "fhir:name/fhir:given"),
            lastname    = attr_val(pat, "fhir:name/fhir:family"),
            birthdate   = attr_val(pat, "fhir:birthDate"),
            deceased_dt = parse_zdt(deceased_str),
        )
    end

    # ── Location lookup: FHIR id → (identifier, parent_fhir_id)
    # parent_fhir_id is set when the Location has a <partOf> (i.e. it is a sector).
    locations = Dict{String, NamedTuple}()
    for loc in EzXML.findall("//fhir:Location", root, ns)
        fhir_id        = attr_val(loc, "fhir:id")
        identifier_val = attr_val(loc, "fhir:identifier/fhir:value")
        (ismissing(fhir_id) || ismissing(identifier_val)) && continue
        part_of_ref    = attr_val(loc, "fhir:partOf/fhir:reference")
        parent_fhir_id = ismissing(part_of_ref) ? missing : ref_id(part_of_ref)
        locations[fhir_id] = (identifier = identifier_val, parent_fhir_id = parent_fhir_id)
    end

    # ── One row per (Encounter × location entry) ──────────────────────────────
    rows = []
    for enc in EzXML.findall("//fhir:Encounter", root, ns)
        subj_ref = attr_val(enc, "fhir:subject/fhir:reference")
        ismissing(subj_ref) && continue
        pat_fhir_id = ref_id(subj_ref)
        pat_info    = get(patients, pat_fhir_id, missing)
        ismissing(pat_info) && continue

        hosp_in  = attr_val(enc, "fhir:actualPeriod/fhir:start")
        hosp_out = attr_val(enc, "fhir:actualPeriod/fhir:end")

        loc_els = EzXML.findall("fhir:location", enc, ns)
        for (loc_idx, loc_el) in enumerate(loc_els)
            loc_ref   = attr_val(loc_el, "fhir:location/fhir:reference")
            unit_name = attr_val(loc_el, "fhir:location/fhir:display")
            unit_in   = attr_val(loc_el, "fhir:period/fhir:start")
            unit_out  = attr_val(loc_el, "fhir:period/fhir:end")

            # Resolve unit_code_name and sector:
            # - if the referenced Location has a partOf, it is a sector → sector = its identifier,
            #   unit_code_name = parent Location's identifier
            # - otherwise it is a unit → sector = missing
            unit_code_name = missing
            sector_val     = missing
            if !ismissing(loc_ref)
                loc_info = get(locations, ref_id(loc_ref), missing)
                if !ismissing(loc_info)
                    if !ismissing(loc_info.parent_fhir_id)
                        # It's a sector
                        sector_val     = loc_info.identifier
                        parent_info    = get(locations, loc_info.parent_fhir_id, missing)
                        unit_code_name = ismissing(parent_info) ? missing : parent_info.identifier
                    else
                        unit_code_name = loc_info.identifier
                    end
                end
            end

            # Extract room from <form> when coded as location-physical-type "ro"
            room_val = missing
            for form_el in EzXML.findall("fhir:form", loc_el, ns)
                code = attr_val(form_el, "fhir:coding/fhir:code")
                if !ismissing(code) && code == "ro"
                    room_val = attr_val(form_el, "fhir:text")
                    break
                end
            end

            push!(rows, (
                patient_ref              = pat_info.patient_ref,
                firstname                = pat_info.firstname,
                lastname                 = pat_info.lastname,
                birthdate                = parse_date(pat_info.birthdate),
                hospitalization_in_time  = parse_zdt(hosp_in),
                hospitalization_out_time = parse_zdt(hosp_out),
                unit_code_name           = unit_code_name,
                unit_name                = unit_name,
                sector                   = sector_val,
                room                     = room_val,
                unit_in_time             = parse_zdt(unit_in),
                unit_out_time            = parse_zdt(unit_out),
                patient_died_during_stay = false,  # Will be updated later based on deceasedDateTime
            ))
        end
    end

    # ── Mark patient_died_during_stay based on Patient.deceasedDateTime ───────
    df = DataFrame(rows)

    for (pat_fhir_id, pat_info) in patients
        deceased_dt = pat_info.deceased_dt
        ismissing(deceased_dt) && continue

        # Find rows for this patient where deceased_dt falls within hospitalization period
        pat_ref_str = pat_info.patient_ref
        matching_rows = findall(df.patient_ref .== pat_ref_str)

        death_matched = false
        for row_idx in matching_rows
            hosp_in_dt  = df[row_idx, :hospitalization_in_time]
            hosp_out_dt = df[row_idx, :hospitalization_out_time]

            if !ismissing(hosp_in_dt) && deceased_dt >= hosp_in_dt &&
               (!ismissing(hosp_out_dt) && deceased_dt <= hosp_out_dt)
                # Death occurred during this hospitalization
                # Mark only the last location (unit) of this hospitalization as the death location
                # Find all rows with same patient_ref and hospitalization_in_time
                same_hosp = findall((df.patient_ref .== pat_ref_str) .&
                                   (df.hospitalization_in_time .== hosp_in_dt))
                if !isempty(same_hosp)
                    last_row = same_hosp[end]
                    df[last_row, :patient_died_during_stay] = true
                    death_matched = true
                    break
                end
            end
        end

        # If death didn't match any stay, create a skeleton row
        if !death_matched
            push!(df, (
                patient_ref              = pat_info.patient_ref,
                firstname                = pat_info.firstname,
                lastname                 = pat_info.lastname,
                birthdate                = parse_date(pat_info.birthdate),
                hospitalization_in_time  = missing,
                hospitalization_out_time = deceased_dt,
                unit_code_name           = missing,
                unit_name                = missing,
                sector                   = missing,
                room                     = missing,
                unit_in_time             = missing,
                unit_out_time            = missing,
                patient_died_during_stay = true,
            ))
        end
    end

    return df
end
