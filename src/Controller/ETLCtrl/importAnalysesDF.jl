"""
    importAnalysesDF(
        df::DataFrame,
        encryptionStr::AbstractString
        ;stopAfterXLines::Number = Inf64,
        ignoreEventsAfter::Union{Missing,ZonedDateTime} = missing
    )

Import analyses from a DataFrame.

The DataFrame is expected to have the right columns with the right types (enums must be
enums and dates must be Date or ZonedDateTime).

The DataFrame must have the following columns and types:
  - patient_ref::String
  - firstname::Union{Missing,String}
  - lastname::Union{Missing,String}
  - birthdate::Union{Missing,Date}
  - analysis_ref::String
  - request_time::ZonedDateTime
  - result_time::Union{Missing,ZonedDateTime}
  - sample::Union{Missing,SAMPLE_MATERIAL_TYPE}
  - request_type::ANALYSIS_REQUEST_TYPE
  - result::Union{Missing,ANALYSIS_RESULT_VALUE_TYPE}

When `firstname`, `lastname` and `birthdate` are all provided for a row, the
patient is created on the fly if it does not yet exist (mirroring the behaviour
of `importStaysDF`). This allows an analysis file to be integrated even if no
stays file has been processed first. If any of those three fields is missing,
the existing behaviour is preserved: the patient is looked up by `patient_ref`
only, and an error is raised when no patient matches.
"""
function ETLCtrl.importAnalysesDF(
    df::DataFrame,
    encryptionStr::AbstractString
    ;stopAfterXLines::Number = Inf64,
    ignoreEventsAfter::Union{Missing,ZonedDateTime} = missing
)

    @info (
      "\n# #################################### #"
    * "\n# Starting the integration of analyses #"
    * "\n# #################################### #"
    )

    # Input file can be empty
    if isempty(df)
        return DataFrame()
    end

    # Create an row number column so that we can go back to exact location in the source file
    df.sourceRowNumber = 1:nrow(df)

    @info "nrow(df) BEFORE filter[$(nrow(df))]"

    # Group by patient_ref and process each patient's analyses in parallel
    grouped = DataFrames.groupby(df, :patient_ref)

    dfOfRowsInError = @showprogress pmap(1:length(grouped)) do i
        ETLCtrl.importAnalysesDF(
            grouped[i],
            encryptionStr;
            stopAfterXLines = stopAfterXLines,
            ignoreEventsAfter = ignoreEventsAfter
        )
    end |>
    n -> vcat(n...)

    return dfOfRowsInError

end

"""
    importAnalysesDF(
        subdf::SubDataFrame,
        encryptionStr::AbstractString
        ;stopAfterXLines::Number = Inf64,
        ignoreEventsAfter::Union{Missing,ZonedDateTime} = missing
    )

Import analyses from a SubDataFrame for a single patient.

This method processes analyses grouped by patient_ref and is called by the main
importAnalysesDF(DataFrame, ...) method.
"""
function ETLCtrl.importAnalysesDF(
    subdf::SubDataFrame,
    encryptionStr::AbstractString
    ;stopAfterXLines::Number = Inf64,
    ignoreEventsAfter::Union{Missing,ZonedDateTime} = missing
)

    TRAQUERUtil.createDBConnAndExecute() do dbconn

        # Create an empty DataFrame for storing problems
        dfOfRowsInError = DataFrame(
            lineNumInSrcFile = Vector{Int}(),
            error = Vector{String}()
        )

        _tz = TRAQUERUtil.getTimeZone()

        counter = 0
        sourceRowNumber = 0

        for r in eachrow(subdf)

            try

                sourceRowNumber = hasproperty(r, :sourceRowNumber) ? r.sourceRowNumber : sourceRowNumber + 1

                counter += 1 # for debug
                if counter > stopAfterXLines # for debug
                    @info "We exit here because it was asked to stop after line[$stopAfterXLines]"
                    break # for debug
                end # for debug

                # Check if NIP_PATIENT is missing
                if ismissing(r.patient_ref)
                    error("Error at line[$sourceRowNumber], patient_ref is missing")
                end

                # Check if analysys ref is missing
                if ismissing(r.analysis_ref)
                    error("Error at line[$sourceRowNumber], analysis_ref is missing")
                end

                patientRef = r.patient_ref
                firstname  = hasproperty(r, :firstname)  ? r.firstname  : missing
                lastname   = hasproperty(r, :lastname)   ? r.lastname   : missing
                birthdate  = hasproperty(r, :birthdate)  ? r.birthdate  : missing
                analysisRef = r.analysis_ref
                requestTime = r.request_time
                resultTime = r.result_time
                sample = r.sample
                requestType = r.request_type
                result = r.result

                # We may want to simulate that we are at a given point in time, in which case
                # some information need to be ignored
                if !ismissing(ignoreEventsAfter)
                    if requestTime > ignoreEventsAfter
                        continue
                    end
                    if (
                        requestTime <= ignoreEventsAfter
                        && !ismissing(resultTime)
                        && resultTime > ignoreEventsAfter
                    )
                        resultTime = missing
                    end
                end

                # Get a patient. When the analyses DataFrame carries a fully-qualified
                # patient (firstname + lastname + birthdate), use
                # `createPatientIfNoExist` so that a patient referenced only
                # by an analyses file can be created on the fly. Otherwise,
                # fall back to looking up an existing patient by ref only
                # (the previous behaviour, which requires the stays file to
                # have been integrated first).
                patient = if !ismissing(firstname) && !ismissing(lastname) && !ismissing(birthdate)
                    PatientCtrl.createPatientIfNoExist(
                        firstname,
                        lastname,
                        birthdate,
                        patientRef,
                        encryptionStr,
                        dbconn
                    )
                else
                    PatientCtrl.retrieveOnePatient(patientRef, encryptionStr, dbconn)
                end

                if ismissing(patient)
                    error("Problem at line[$sourceRowNumber]."
                    * " Unable to find patient for ref[$patientRef]. "
                    * " Maybe a file of stays has not been integrated.")
                end

                # Get a stay
                stay = StayCtrl.retrieveOneStayContainingDateTime(patient, requestTime, dbconn)

                if ismissing(stay)
                    error(
                    "Problem at row[$sourceRowNumber] of dataframe."
                    * " Unable to find a stay for patient.id[$(patient.id)]"
                    * " patient.ref[$(patientRef)]"
                    * " starting before the date of the analyis request[$requestTime].")
                end

                analysisResult = AnalysisResult(
                    patient = patient,
                    stay = stay,
                    sampleMaterialType = sample,
                    requestTime = requestTime,
                    resultTime = resultTime,
                    result = result,
                    resultRawText = missing,
                    requestType = requestType,
                )

                analysisResult = AnalysisResultCtrl.upsert!(
                    analysisResult,
                    analysisRef,
                    encryptionStr,
                    dbconn
                )

            catch e
                errorDescription = TRAQUERUtil.formatExceptionAndStackTraceCore(
                    e, stacktrace(catch_backtrace())
                )

                push!(
                    dfOfRowsInError,
                    (
                        lineNumInSrcFile = sourceRowNumber,
                        error = errorDescription
                    )
                )
            end

        end # `for r in eachrow(subdf)`

        return dfOfRowsInError

    end # ENDOF createDBConnAndExecute do function

end
