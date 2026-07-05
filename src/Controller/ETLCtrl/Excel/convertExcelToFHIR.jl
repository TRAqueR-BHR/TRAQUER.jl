"""
    convertExcelToFHIR(
        staysExcelFilePath::String,
        analysisExcelFilePath::String,
        xmlOutputFilePath::String
    )

Convert the given Excel files to FHIR XML format and save the output to the specified file path.

The stays Excel file is expected to have columns:
  patient_ref, firstname, lastname, birthdate,
  unit_code_name, unit_name,
  unit_in_time, unit_out_time,
  hospitalization_in_time, hospitalization_out_time,
  room, out (devenir)

When the `sector` column is non-empty, a child Location resource is emitted for the
sector with a `partOf` reference to its parent unit Location. The Encounter.location
element then references the sector Location instead of the unit Location directly.

The `room` value is emitted as a FHIR `form` element on each `Encounter.location` entry,
using the `http://terminology.hl7.org/CodeSystem/location-physical-type` coding system
with code `ro` (Room) and the room identifier as the `<text>` value.

The analyses Excel file is expected to have columns:
  patient_ref, firstname, lastname, birthdate,
  analysis_ref, status, request_time, result_time,
  sample, request_type, result, result_raw_text

The `firstname`, `lastname` and `birthdate` columns are expected to be a
denormalised copy of the corresponding patient columns from the stays Excel
file, joined on `patient_ref`. They are used to emit the `Patient` resource
for every `patient_ref` that appears in the analyses file (the stays Excel
remains the source of truth for `Location` and `Encounter` resources).

Returns the XML string and writes it to xmlOutputFilePath.
"""
function ETLCtrl.Excel.convertExcelToFHIR(
    staysExcelFilePath::String,
    analysisExcelFilePath::String,
    xmlOutputFilePath::String
)

    # ── Load data ────────────────────────────────────────────────────────────
    stays_df    = XLSX.readtable(staysExcelFilePath,    1) |> DataFrame
    analyses_df = XLSX.readtable(analysisExcelFilePath, 1) |> DataFrame

    # ── Helpers ──────────────────────────────────────────────────────────────

    """Format a date/datetime value to an ISO-8601 FHIR string.
    FHIR R5 requires a numeric UTC offset (e.g. +01:00) on all dateTime values.
    The offset is resolved per-value so that DST transitions are handled correctly."""
    tz = TRAQUERUtil.getTimeZone()
    function fmt(val)
        ismissing(val) && return missing
        if val isa DateTime
            (Dates.hour(val) == 0 && Dates.minute(val) == 0 && Dates.second(val) == 0) ?
                Dates.format(val, "yyyy-mm-dd") :
                Dates.format(ZonedDateTime(val, tz), "yyyy-mm-ddTHH:MM:SSzzz")
        elseif val isa Date
            Dates.format(val, "yyyy-mm-dd")
        else
            # Try to parse as DateTime and reformat with timezone
            s = string(val)
            try
                dt = DateTime(s)
                return (Dates.hour(dt) == 0 && Dates.minute(dt) == 0 && Dates.second(dt) == 0) ?
                    Dates.format(dt, "yyyy-mm-dd") :
                    Dates.format(ZonedDateTime(dt, tz), "yyyy-mm-ddTHH:MM:SSzzz")
            catch
            end
            s
        end
    end

    """Escape characters that are special in XML attribute values / text."""
    function esc(val)
        s = string(val)
        s = replace(s, "&"  => "&amp;")
        s = replace(s, "<"  => "&lt;")
        s = replace(s, ">"  => "&gt;")
        s = replace(s, "\"" => "&quot;")
        s
    end

    """Convert any date-like value to DateTime for range comparisons."""
    function to_dt(val)
        ismissing(val) && return missing
        val isa DateTime && return val
        val isa Date    && return DateTime(val)
        if val isa String
            try return DateTime(val) catch; end
            try return DateTime(Date(val)) catch; end
        end
        missing
    end

    """Format a date/datetime value to a full ISO-8601 string with timezone offset (always ZonedDateTime).
    Used for unit_in_time, unit_out_time, hospitalization_in_time, hospitalization_out_time."""
    function fmt_zdt(val)
        ismissing(val) && return missing
        if val isa ZonedDateTime
            return Dates.format(val, "yyyy-mm-ddTHH:MM:SSzzz")
        elseif val isa DateTime
            return Dates.format(ZonedDateTime(val, tz), "yyyy-mm-ddTHH:MM:SSzzz")
        elseif val isa Date
            return Dates.format(ZonedDateTime(DateTime(val), tz), "yyyy-mm-ddTHH:MM:SSzzz")
        else
            s = string(val)
            try
                dt = DateTime(s)
                return Dates.format(ZonedDateTime(dt, tz), "yyyy-mm-ddTHH:MM:SSzzz")
            catch; end
            try
                d = Date(s)
                return Dates.format(ZonedDateTime(DateTime(d), tz), "yyyy-mm-ddTHH:MM:SSzzz")
            catch; end
            s
        end
    end

    """Build a FHIR Location id from a unit code name."""
    loc_id(code) = "loc-" * replace(string(code), r"\s+" => "-")

    """Build a FHIR Location id for a sector within a unit."""
    loc_id_sector(unit_code, sector) = loc_id(unit_code) * "-" * replace(string(sector), r"\s+" => "-")

    # ── Build XML ────────────────────────────────────────────────────────────
    io = IOBuffer()

    println(io, "<?xml version='1.0' encoding='utf-8'?>")
    println(io, """<Bundle xmlns=\"http://hl7.org/fhir\">""")
    println(io, "    <type value=\"transaction\" />")

    # ── Patients ──────────────────────────────────────────────────────────────
    # Emit a Patient resource for every `patient_ref` that appears in either
    # the stays or the analyses DataFrame. Patient details are taken from the
    # analyses DataFrame (where `firstname`/`lastname`/`birthdate` are
    # populated from the stays Excel via `patient_ref`); for patients that
    # appear in stays but not in analyses, we fall back to the stays
    # DataFrame. The stays DataFrame is also consulted for
    # `patient_died_during_stay`, so death information is preserved.
    patient_info = Dict{Any, NamedTuple}()
    for r in eachrow(unique(analyses_df, :patient_ref))
        patient_info[r.patient_ref] = (
            firstname = r.firstname,
            lastname  = r.lastname,
            birthdate = r.birthdate,
        )
    end
    for r in eachrow(unique(stays_df, :patient_ref))
        if !haskey(patient_info, r.patient_ref)
            patient_info[r.patient_ref] = (
                firstname = r.firstname,
                lastname  = r.lastname,
                birthdate = r.birthdate,
            )
        end
    end

    # Ordered emission: stays order first (preserves the previous output
    # ordering), then any patient_refs present only in analyses.
    patients_to_emit = Tuple{Any, NamedTuple}[]
    seen = Set{Any}()
    for r in eachrow(unique(stays_df, :patient_ref))
        if !(r.patient_ref in seen)
            push!(patients_to_emit, (r.patient_ref, patient_info[r.patient_ref]))
            push!(seen, r.patient_ref)
        end
    end
    for r in eachrow(unique(analyses_df, :patient_ref))
        if !(r.patient_ref in seen)
            push!(patients_to_emit, (r.patient_ref, patient_info[r.patient_ref]))
            push!(seen, r.patient_ref)
        end
    end

    for (patient_ref, info) in patients_to_emit
        pid = "patient-$(patient_ref)"
        # Check if this patient died during any stay
        pat_rows = filter(r -> string(r.patient_ref) == string(patient_ref), eachrow(stays_df))
        died_row = findfirst(r -> !ismissing(r.patient_died_during_stay) && r.patient_died_during_stay == true, pat_rows)
        deceased_xml = if !isnothing(died_row)
            death_dt = pat_rows[died_row].hospitalization_out_time
            ismissing(death_dt) ? "" : """
                <deceasedDateTime value=\"$(fmt_zdt(death_dt))\" />"""
        else
            ""
        end
        print(io, """
    <entry>
        <fullUrl value="urn:uuid:$(pid)" />
        <resource>
            <Patient>
                <id value="$(pid)" />
                <identifier>
                    <value value="$(esc(patient_ref))" />
                </identifier>
                <name>
                    <family value="$(esc(uppercase(string(info.lastname))))" />
                    <given value="$(esc(info.firstname))" />
                </name>
                <birthDate value="$(fmt(info.birthdate))" />$(deceased_xml)
            </Patient>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Patient/$(pid)" />
        </request>
    </entry>
""")
    end

    # ── Locations ─────────────────────────────────────────────────────────────
    for row in eachrow(unique(stays_df, :unit_code_name))
        lid = loc_id(row.unit_code_name)
        print(io, """
    <entry>
        <fullUrl value="urn:uuid:$(lid)" />
        <resource>
            <Location>
                <id value="$(lid)" />
                <identifier>
                    <value value="$(esc(row.unit_code_name))" />
                </identifier>
                <name value="$(esc(row.unit_name))" />
            </Location>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Location/$(lid)" />
        </request>
    </entry>
""")
    end

    # ── Sector Locations (child of unit, emitted when sector column is non-empty) ──
    sector_rows = filter(r -> !ismissing(r.sector) && !isempty(strip(string(r.sector))), eachrow(stays_df))
    if !isempty(sector_rows)
        for row in eachrow(unique(DataFrame(sector_rows), [:unit_code_name, :sector]))
            sid = loc_id_sector(row.unit_code_name, row.sector)
            lid = loc_id(row.unit_code_name)
            print(io, """
    <entry>
        <fullUrl value="urn:uuid:$(sid)" />
        <resource>
            <Location>
                <id value="$(sid)" />
                <identifier>
                    <value value="$(esc(row.sector))" />
                </identifier>
                <name value="$(esc(row.sector))" />
                <partOf>
                    <reference value="urn:uuid:$(lid)" />
                </partOf>
            </Location>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Location/$(sid)" />
        </request>
    </entry>
""")
        end
    end

    # ── Encounters ────────────────────────────────────────────────────────────
    # Group stays by (patient_ref, hospitalization_in_time) — one Encounter per
    # hospitalisation, with one <location> entry per unit row.
    enc_counter = 0
    # (patient_ref_str, hosp_in_str) => (enc_id, hosp_in_dt, hosp_out_dt)
    enc_lookup  = Dict{Tuple{String,String}, NamedTuple}()

    for grp in DataFrames.groupby(stays_df, [:patient_ref, :hospitalization_in_time])
        enc_counter += 1
        eid        = "enc-$(enc_counter)"
        first_row  = grp[1, :]
        pat_ref    = string(first_row.patient_ref)
        hosp_in    = first_row.hospitalization_in_time
        hosp_out   = first_row.hospitalization_out_time
        status     = ismissing(hosp_out) ? "in-progress" : "completed"

        patient_died = any(r -> !ismissing(r.patient_died_during_stay) && r.patient_died_during_stay == true, eachrow(grp))

        enc_lookup[(pat_ref, string(hosp_in))] = (
            enc_id      = eid,
            hosp_in_dt  = to_dt(hosp_in),
            hosp_out_dt = to_dt(hosp_out)
        )

        # Build <location> sub-elements
        loc_buf = IOBuffer()
        for lr in eachrow(grp)
            # Use sector Location if sector is present, otherwise the unit Location
            has_sector = !ismissing(lr.sector) && !isempty(strip(string(lr.sector)))
            ref_lid    = has_sector ? loc_id_sector(lr.unit_code_name, lr.sector) : loc_id(lr.unit_code_name)
            uin_str = fmt_zdt(lr.unit_in_time)
            print(loc_buf, """
                <location>
                    <location>
                        <reference value="urn:uuid:$(ref_lid)" />
                        <display value="$(esc(lr.unit_name))" />
                    </location>""")
            if !ismissing(lr.room) && !isempty(strip(string(lr.room)))
                print(loc_buf, """
                    <form>
                        <coding>
                            <system value="http://terminology.hl7.org/CodeSystem/location-physical-type" />
                            <code value="ro" />
                            <display value="Room" />
                        </coding>
                        <text value="$(esc(lr.room))" />
                    </form>""")
            end
            print(loc_buf, """
                    <period>
                        <start value="$(uin_str)" />""")
            if !ismissing(lr.unit_out_time)
                print(loc_buf, """
                        <end value="$(fmt_zdt(lr.unit_out_time))" />""")
            end
            println(loc_buf, """
                    </period>
                </location>""")
        end

        print(io, """
    <entry>
        <fullUrl value="urn:uuid:$(eid)" />
        <resource>
            <Encounter>
                <id value="$(eid)" />
                <status value="$(status)" />
                <class>
                    <coding>
                        <system value="http://terminology.hl7.org/CodeSystem/v3-ActCode" />
                        <code value="IMP" />
                    </coding>
                </class>
                <subject>
                    <reference value="urn:uuid:patient-$(pat_ref)" />
                </subject>
                <actualPeriod>
                    <start value="$(fmt_zdt(hosp_in))" />""")
        if !ismissing(hosp_out)
            print(io, """
                    <end value="$(fmt_zdt(hosp_out))" />""")
        end
        admission_xml = patient_died ? """
                <admission>
                    <dischargeDisposition>
                        <coding>
                            <system value=\"http://terminology.hl7.org/CodeSystem/discharge-disposition\" />
                            <code value=\"exp\" />
                            <display value=\"Expired\" />
                        </coding>
                    </dischargeDisposition>
                </admission>""" : ""
        print(io, """
                </actualPeriod>$(admission_xml)
$(rstrip(String(take!(loc_buf))))
            </Encounter>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Encounter/$(eid)" />
        </request>
    </entry>
""")
    end

    # ── Helper: find Encounter for a given patient + analysis time ─────────────
    function find_encounter(pat_ref_str::String, analysis_dt)
        # 1. Look for an encounter whose period contains the analysis time
        if !ismissing(analysis_dt)
            for ((p, _), info) in enc_lookup
                p != pat_ref_str && continue
                in_dt  = info.hosp_in_dt
                out_dt = info.hosp_out_dt
                ismissing(in_dt) && continue
                in_range = analysis_dt >= in_dt &&
                           (ismissing(out_dt) || analysis_dt <= out_dt)
                in_range && return info.enc_id
            end
        end
        # 2. Fallback: first encounter for this patient
        for ((p, _), info) in enc_lookup
            p == pat_ref_str && return info.enc_id
        end
        return missing
    end

    # ── Helper: find Location (unit) for a given patient + time ──────────────
    function find_location(pat_ref_str::String, time_dt)
        ismissing(time_dt) && return missing
        for row in eachrow(stays_df)
            string(row.patient_ref) != pat_ref_str && continue
            in_dt  = to_dt(row.unit_in_time)
            out_dt = to_dt(row.unit_out_time)
            ismissing(in_dt) && continue
            (time_dt >= in_dt && (ismissing(out_dt) || time_dt <= out_dt)) &&
                return loc_id(row.unit_code_name)
        end
        # fallback: last known unit for this patient
        last_row = nothing
        for row in eachrow(stays_df)
            string(row.patient_ref) == pat_ref_str && (last_row = row)
        end
        isnothing(last_row) ? missing : loc_id(last_row.unit_code_name)
    end

    # ── ServiceRequests ────────────────────────────────────────────────────────
    for row in eachrow(analyses_df)
        ar        = string(row.analysis_ref)
        pat_ref   = string(row.patient_ref)
        req_str   = fmt(row.request_time)
        res_val   = row.result
        has_result = !ismissing(res_val) && !isempty(strip(string(res_val)))
        sr_status  = has_result ? "completed" : "active"
        req_type   = esc(string(row.request_type))

        req_dt      = to_dt(row.request_time)
        matched_enc = find_encounter(pat_ref, req_dt)
        matched_loc = find_location(pat_ref, req_dt)
        enc_xml_sr  = ismissing(matched_enc) ? "" : """
            <encounter>
                <reference value="urn:uuid:$(matched_enc)" />
            </encounter>"""
        req_xml_sr  = ismissing(matched_loc) ? "" : """
            <requester>
                <reference value="urn:uuid:$(matched_loc)" />
            </requester>"""

        print(io, """
    <entry>
        <fullUrl value="urn:uuid:sr-$(ar)" />
        <resource>
            <ServiceRequest>
                <id value="sr-$(ar)" />
                <identifier>
                    <system value="urn:analysis-ref" />
                    <value value="$(esc(ar))" />
                </identifier>
                <status value="$(sr_status)" />
                <intent value="order" />
                <code>
                    <concept>
                        <coding>
                            <system value="https://traquer.org" />
                            <code value="$(req_type)" />
                        </coding>
                    </concept>
                </code>
                <subject>
                    <reference value="urn:uuid:patient-$(pat_ref)" />
                </subject>$(enc_xml_sr)
                <authoredOn value="$(req_str)" />$(req_xml_sr)
                <specimen>
                    <reference value="urn:uuid:spec-$(ar)" />
                </specimen>
            </ServiceRequest>
        </resource>
        <request>
            <method value="PUT" />
            <url value="ServiceRequest/sr-$(ar)" />
        </request>
    </entry>
""")
    end

    # ── Specimens ─────────────────────────────────────────────────────────────
    for row in eachrow(analyses_df)
        ar      = string(row.analysis_ref)
        pat_ref = string(row.patient_ref)
        stype   = esc(row.sample)
        req_str = fmt(row.request_time)
        res_t   = row.result_time

        print(io, """
    <entry>
        <fullUrl value="urn:uuid:spec-$(ar)" />
        <resource>
            <Specimen>
                <id value="spec-$(ar)" />
                <identifier>
                    <value value="$(esc(ar))" />
                </identifier>
                <type>
                    <text value="$(stype)" />
                </type>
                <subject>
                    <reference value="urn:uuid:patient-$(pat_ref)" />
                </subject>
                <receivedTime value="$(req_str)" />
                <request>
                    <reference value="urn:uuid:sr-$(ar)" />
                </request>
                <collection>
                    <collectedDateTime value="$(req_str)" />
                </collection>""")
        if !ismissing(res_t)
            print(io, """
                <processing>
                    <description value="Validation du résultat" />
                    <timeDateTime value="$(fmt(res_t))" />
                </processing>""")
        end
        print(io, """
            </Specimen>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Specimen/spec-$(ar)" />
        </request>
    </entry>
""")
    end

    # ── Tasks (analyses without result: sample taken and sent to the lab culture in
    #    progress) ────────────────────────────────────────────────────────────────────────
    for row in eachrow(analyses_df)
        res_val = row.result

        # Only create a Task if status == in_progress
        if row.status !== "in_progress"
            continue
        end

        ar      = string(row.analysis_ref)
        pat_ref = string(row.patient_ref)

        req_dt      = to_dt(row.request_time)
        matched_enc = find_encounter(pat_ref, req_dt)
        enc_xml_t   = ismissing(matched_enc) ? "" : """
            <encounter>
                <reference value="urn:uuid:$(matched_enc)" />
            </encounter>"""

        print(io, """
    <entry>
        <fullUrl value="urn:uuid:task-$(ar)" />
        <resource>
            <Task>
                <id value="task-$(ar)" />
                <status value="in-progress" />
                <intent value="order" />
                <code>
                    <coding>
                        <system value="http://hl7.org/fhir/CodeSystem/task-code" />
                        <code value="fulfill" />
                        <display value="Fulfill the focal request" />
                    </coding>
                </code>
                <focus>
                    <valueReference>
                        <reference value="urn:uuid:sr-$(ar)" />
                    </valueReference>
                </focus>
                <for>
                    <reference value="urn:uuid:patient-$(pat_ref)" />
                </for>$(enc_xml_t)
                <executionPeriod>
                    <start value="$(fmt(row.request_time))" />
                </executionPeriod>
            </Task>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Task/task-$(ar)" />
        </request>
    </entry>
""")
    end

    # ── Observations (only rows with a result) ────────────────────────────────
    for row in eachrow(analyses_df)
        res_val = row.result
        (ismissing(res_val) || isempty(strip(string(res_val)))) && continue

        ar      = string(row.analysis_ref)
        pat_ref = string(row.patient_ref)
        stype   = esc(row.sample)
        res_t   = row.result_time
        eff_str = ismissing(res_t) ? fmt(row.request_time) : fmt(res_t)

        # FHIR interpretation code
        interp_code    = lowercase(strip(string(res_val))) == "positive" ? "POS" : "NEG"
        interp_display = interp_code == "POS" ? "Positive" : "Negative"

        # Encounter reference
        analysis_dt  = to_dt(ismissing(res_t) ? row.request_time : res_t)
        matched_enc  = find_encounter(pat_ref, analysis_dt)
        enc_xml      = ismissing(matched_enc) ? "" : """
                <encounter>
                    <reference value="urn:uuid:$(matched_enc)" />
                </encounter>"""

        # Optional note from result_raw_text
        raw = row.result_raw_text
        note_xml = (ismissing(raw) || string(raw) == "missing") ? "" : """
                <note>
                    <text value="$(esc(raw))" />
                </note>"""

        print(io, """
    <entry>
        <fullUrl value="urn:uuid:obs-$(ar)" />
        <resource>
            <Observation>
                <id value="obs-$(ar)" />
                <basedOn>
                    <reference value="urn:uuid:sr-$(ar)" />
                </basedOn>
                <status value="final" />
                <code>
                    <text value="$(stype)" />
                </code>
                <subject>
                    <reference value="urn:uuid:patient-$(pat_ref)" />
                </subject>$(enc_xml)
                <effectiveDateTime value="$(eff_str)" />
                <interpretation>
                    <coding>
                        <system
                            value="http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation" />
                        <code value="$(interp_code)" />
                        <display value="$(interp_display)" />
                    </coding>
                </interpretation>$(note_xml)
                <specimen>
                    <reference value="urn:uuid:spec-$(ar)" />
                </specimen>
            </Observation>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Observation/obs-$(ar)" />
        </request>
    </entry>
""")
    end

    println(io, "</Bundle>")
    xml_content = String(take!(io))

    # Write output file (create parent directories if needed)
    let dir = dirname(xmlOutputFilePath)
        !isempty(dir) && mkpath(dir)
    end
    open(xmlOutputFilePath, "w") do f
        write(f, xml_content)
    end

    # Format the xml output
    ETLCtrl.FHIR.formatXMLFile(xmlOutputFilePath)

    # Make sure the xml passes the FHIR schema validation (throws if invalid)
    _valid, _errors = ETLCtrl.FHIR.validateAgainstSchema(
        xmlOutputFilePath,
        "src/Controller/ETLCtrl/FHIR/xsd/r5/fhir-r5-single.xsd"
    )

    if _valid == false
        error_msg = "Generated XML file does not conform to FHIR schema. Errors:\n"
        for e in _errors
            error_msg *= "  - $(e.fileName):$(e.lineNumber): $(e.errorMessage)\n"
        end
        throw(ErrorException(error_msg))
    end

    return read(xmlOutputFilePath, String)
end
