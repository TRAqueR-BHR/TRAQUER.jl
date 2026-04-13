"""
    getStaysDataFrameFromXML(xmlFilePath::String)

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
"""
function ETLCtrl.FHIR.getStaysDataFrameFromXML(xmlFilePath::String)
    xmlDoc = ETLCtrl.FHIR.loadXMLFile(xmlFilePath)
    root   = EzXML.root(xmlDoc)
    ns     = ["fhir" => "http://hl7.org/fhir"]

    # Helper: return the @value attribute of the first XPath match, or missing
    function attr_val(node, xpath)
        n = EzXML.findfirst(xpath, node, ns)
        isnothing(n) ? missing : n["value"]
    end

    # ── Patient lookup: FHIR id → (patient_ref, firstname, lastname, birthdate)
    patients = Dict{String, NamedTuple}()
    for pat in EzXML.findall("//fhir:Patient", root, ns)
        fhir_id = attr_val(pat, "fhir:id")
        ismissing(fhir_id) && continue
        patients[fhir_id] = (
            patient_ref = attr_val(pat, "fhir:identifier/fhir:value"),
            firstname   = attr_val(pat, "fhir:name/fhir:given"),
            lastname    = attr_val(pat, "fhir:name/fhir:family"),
            birthdate   = attr_val(pat, "fhir:birthDate"),
        )
    end

    # ── Location lookup: FHIR id → unit_code_name (identifier/value)
    locations = Dict{String, String}()
    for loc in EzXML.findall("//fhir:Location", root, ns)
        fhir_id        = attr_val(loc, "fhir:id")
        unit_code_name = attr_val(loc, "fhir:identifier/fhir:value")
        (ismissing(fhir_id) || ismissing(unit_code_name)) && continue
        locations[fhir_id] = unit_code_name
    end

    # ── One row per (Encounter × location entry) ──────────────────────────────
    rows = []
    for enc in EzXML.findall("//fhir:Encounter", root, ns)
        subj_ref = attr_val(enc, "fhir:subject/fhir:reference")
        ismissing(subj_ref) && continue
        pat_fhir_id = last(split(subj_ref, "/"))
        pat_info    = get(patients, pat_fhir_id, missing)
        ismissing(pat_info) && continue

        hosp_in  = attr_val(enc, "fhir:actualPeriod/fhir:start")
        hosp_out = attr_val(enc, "fhir:actualPeriod/fhir:end")

        for loc_el in EzXML.findall("fhir:location", enc, ns)
            loc_ref  = attr_val(loc_el, "fhir:location/fhir:reference")
            unit_name = attr_val(loc_el, "fhir:location/fhir:display")
            unit_in   = attr_val(loc_el, "fhir:period/fhir:start")
            unit_out  = attr_val(loc_el, "fhir:period/fhir:end")

            unit_code_name = if !ismissing(loc_ref)
                get(locations, last(split(loc_ref, "/")), missing)
            else
                missing
            end

            push!(rows, (
                patient_ref              = pat_info.patient_ref,
                firstname                = pat_info.firstname,
                lastname                 = pat_info.lastname,
                birthdate                = pat_info.birthdate,
                hospitalization_in_time  = hosp_in,
                hospitalization_out_time = hosp_out,
                unit_code_name           = unit_code_name,
                unit_name                = unit_name,
                sector                   = missing,
                room                     = missing,
                unit_in_time             = unit_in,
                unit_out_time            = unit_out,
            ))
        end
    end

    return DataFrame(rows)
end
