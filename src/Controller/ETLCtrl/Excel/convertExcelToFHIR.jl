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

The `room` value is emitted as a FHIR `form` element on each `Encounter.location` entry,
using the `http://terminology.hl7.org/CodeSystem/location-physical-type` coding system
with code `ro` (Room) and the room identifier as the `<text>` value.

The analyses Excel file is expected to have columns:
  patient_ref, analysis_ref, request_time, result_time,
  sample, request_type, result, result_raw_text

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

    # ── Build XML ────────────────────────────────────────────────────────────
    io     = IOBuffer()
    org_id = "org-demo"

    println(io, "<?xml version='1.0' encoding='utf-8'?>")
    println(io, """<Bundle xmlns=\"http://hl7.org/fhir\">""")
    println(io, "    <type value=\"transaction\" />")

    # ── Organization ─────────────────────────────────────────────────────────
    print(io, """
    <entry>
        <fullUrl value="urn:uuid:$(org_id)" />
        <resource>
            <Organization>
                <id value="$(org_id)" />
                <name value="Demo Hospital" />
            </Organization>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Organization/$(org_id)" />
        </request>
    </entry>
""")

    # ── Patients ──────────────────────────────────────────────────────────────
    for row in eachrow(unique(stays_df, :patient_ref))
        pid = "patient-$(row.patient_ref)"
        print(io, """
    <entry>
        <fullUrl value="urn:uuid:$(pid)" />
        <resource>
            <Patient>
                <id value="$(pid)" />
                <identifier>
                    <value value="$(esc(row.patient_ref))" />
                </identifier>
                <name>
                    <family value="$(esc(uppercase(string(row.lastname))))" />
                    <given value="$(esc(row.firstname))" />
                </name>
                <birthDate value="$(fmt(row.birthdate))" />
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
                <managingOrganization>
                    <reference value="Organization/$(org_id)" />
                </managingOrganization>
            </Location>
        </resource>
        <request>
            <method value="PUT" />
            <url value="Location/$(lid)" />
        </request>
    </entry>
""")
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

        enc_lookup[(pat_ref, string(hosp_in))] = (
            enc_id      = eid,
            hosp_in_dt  = to_dt(hosp_in),
            hosp_out_dt = to_dt(hosp_out)
        )

        # Build <location> sub-elements
        loc_buf = IOBuffer()
        for lr in eachrow(grp)
            lid     = loc_id(lr.unit_code_name)
            uin_str = fmt_zdt(lr.unit_in_time)
            print(loc_buf, """
                <location>
                    <location>
                        <reference value="Location/$(lid)" />
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
                    <reference value="Patient/patient-$(pat_ref)" />
                </subject>
                <serviceProvider>
                    <reference value="Organization/$(org_id)" />
                </serviceProvider>
                <actualPeriod>
                    <start value="$(fmt_zdt(hosp_in))" />""")
        if !ismissing(hosp_out)
            print(io, """
                    <end value="$(fmt_zdt(hosp_out))" />""")
        end
        print(io, """
                </actualPeriod>
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
                    <reference value="Patient/patient-$(pat_ref)" />
                </subject>
                <receivedTime value="$(req_str)" />
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
                    <reference value="Encounter/$(matched_enc)" />
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
                <status value="final" />
                <code>
                    <text value="$(stype)" />
                </code>
                <subject>
                    <reference value="Patient/patient-$(pat_ref)" />
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
                    <reference value="Specimen/spec-$(ar)" />
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
