"""
    getAnalysesDataFrameFromXML(xmlFilePath::String)

Extract analyses from an FHIR XML file and return them as a DataFrame.

Columns in the DataFrame are the following:
- patient_ref (a reference to the patient)
- analysis_ref (a unique reference for the analysis, e.g. "analysis-1", "analysis-2", etc.)
- status (one of requested, in_progress, done — see ANALYSIS_REQUEST_STATUS_TYPE enum)
- request_time
- result_time
- sample (a description of the sample, e.g. "stool" — see SAMPLE_MATERIAL_TYPE enum)
- request_type (the type of request — see ANALYSIS_REQUEST_TYPE enum)
- result (one of positive, negative, cancelled, suspicion — see ANALYSIS_RESULT_VALUE_TYPE enum)

The mapping from FHIR resources is:
- ServiceRequest  → analysis_ref (identifier/value), request_time (authoredOn),
                    request_type (code/concept/coding/code), patient_ref (subject/reference)
- Specimen        → sample (type/text), linked to ServiceRequest via request/reference
- Task            → when status = "in-progress", marks the linked ServiceRequest as in_progress
- Observation     → result (interpretation/coding/code), result_time (effectiveDateTime),
                    linked to ServiceRequest via basedOn/reference; presence marks status as done
"""
function ETLCtrl.FHIR.getAnalysesDataFrameFromXML(xmlFilePath::String)
    xmlDoc = ETLCtrl.FHIR.loadXMLFile(xmlFilePath)
    root   = EzXML.root(xmlDoc)
    ns     = ["fhir" => "http://hl7.org/fhir"]

    # Helper: return the @value attribute of the first XPath match, or missing
    function attr_val(node, xpath)
        n = EzXML.findfirst(xpath, node, ns)
        isnothing(n) ? missing : n["value"]
    end

    # Helper: parse a FHIR dateTime string to ZonedDateTime, or missing.
    # Handles full ISO-8601 with offset (e.g. "2022-05-02T10:00:00+02:00")
    # and date-only values (e.g. "2022-05-02") treated as midnight UTC.
    function parse_zdt(s)::Union{ZonedDateTime, Missing}
        ismissing(s) && return missing
        if occursin(r"^\d{4}-\d{2}-\d{2}$", s)
            return ZonedDateTime(
                DateTime(s, dateformat"yyyy-mm-dd"),
                TRAQUERUtil.getTimeZone()
            )
        end
        TRAQUERUtil.convertStringToZonedDateTime(s)
    end

    # Map Observation interpretation code → ANALYSIS_RESULT_VALUE_TYPE string
    obs_interp_map = Dict(
        "POS" => "positive",
        "NEG" => "negative",
        "IND" => "suspicion",
        "SUS" => "suspicion",
    )

    # ── Patient lookup: FHIR id → patient_ref (identifier/value) ─────────────
    patients = Dict{String, String}()
    for pat in EzXML.findall("//fhir:Patient", root, ns)
        fhir_id = attr_val(pat, "fhir:id")
        patient_ref = attr_val(pat, "fhir:identifier/fhir:value")
        (ismissing(fhir_id) || ismissing(patient_ref)) && continue
        patients[fhir_id] = patient_ref
    end

    # ── Specimen lookup: FHIR id → sample type text ───────────────────────────
    # Also build reverse index: ServiceRequest FHIR id → sample text
    sr_to_sample = Dict{String, String}()
    for spec in EzXML.findall("//fhir:Specimen", root, ns)
        sample_text = attr_val(spec, "fhir:type/fhir:text")
        ismissing(sample_text) && continue
        for req_el in EzXML.findall("fhir:request", spec, ns)
            sr_ref = attr_val(req_el, "fhir:reference")
            ismissing(sr_ref) && continue
            sr_id = last(split(sr_ref, "/"))
            sr_to_sample[sr_id] = sample_text
        end
    end

    # ── Task lookup: ServiceRequest FHIR id → in_progress flag ───────────────
    sr_in_progress = Set{String}()
    for task in EzXML.findall("//fhir:Task", root, ns)
        status = attr_val(task, "fhir:status")
        (ismissing(status) || status != "in-progress") && continue
        focus_ref = attr_val(task, "fhir:focus/fhir:valueReference/fhir:reference")
        ismissing(focus_ref) && continue
        push!(sr_in_progress, last(split(focus_ref, "/")))
    end

    # ── Observation lookup: ServiceRequest FHIR id → (result, result_time) ───
    sr_to_obs = Dict{String, NamedTuple}()
    for obs in EzXML.findall("//fhir:Observation", root, ns)
        based_on_ref = attr_val(obs, "fhir:basedOn/fhir:reference")
        ismissing(based_on_ref) && continue
        sr_id = last(split(based_on_ref, "/"))

        interp_code  = attr_val(obs, "fhir:interpretation/fhir:coding/fhir:code")
        result_str   = if !ismissing(interp_code)
            get(obs_interp_map, interp_code, missing)
        else
            # fallback: check for explicit "cancelled" status on the observation
            obs_status = attr_val(obs, "fhir:status")
            (!ismissing(obs_status) && obs_status == "cancelled") ? "cancelled" : missing
        end

        result_time = parse_zdt(attr_val(obs, "fhir:effectiveDateTime"))

        sr_to_obs[sr_id] = (result = result_str, result_time = result_time)
    end

    # ── One row per ServiceRequest ─────────────────────────────────────────────
    rows = []
    for sr in EzXML.findall("//fhir:ServiceRequest", root, ns)
        fhir_id = attr_val(sr, "fhir:id")
        ismissing(fhir_id) && continue

        analysis_ref = attr_val(sr, "fhir:identifier/fhir:value")
        request_type = attr_val(sr, "fhir:code/fhir:concept/fhir:coding/fhir:code")
        request_time = parse_zdt(attr_val(sr, "fhir:authoredOn"))

        subj_ref    = attr_val(sr, "fhir:subject/fhir:reference")
        patient_ref = if !ismissing(subj_ref)
            get(patients, last(split(subj_ref, "/")), missing)
        else
            missing
        end

        sample = get(sr_to_sample, fhir_id, missing)

        obs_info    = get(sr_to_obs, fhir_id, nothing)
        result      = isnothing(obs_info) ? missing : obs_info.result
        result_time = isnothing(obs_info) ? missing : obs_info.result_time

        status = if !isnothing(obs_info)
            "done"
        elseif fhir_id in sr_in_progress
            "in_progress"
        else
            "requested"
        end

        push!(rows, (
            patient_ref  = patient_ref,
            analysis_ref = analysis_ref,
            status       = status,
            request_time = request_time,
            result_time  = result_time,
            sample       = sample,
            request_type = request_type,
            result       = result,
        ))
    end

    return DataFrame(rows)
end
