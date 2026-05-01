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
  - analysis_ref::String
  - request_time::ZonedDateTime
  - result_time::Union{Missing,ZonedDateTime}
  - sample::Union{Missing,SAMPLE_MATERIAL_TYPE}
  - request_type::ANALYSIS_REQUEST_TYPE
  - result::Union{Missing,ANALYSIS_RESULT_VALUE_TYPE}
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

    dbconn = TRAQUERUtil.openDBConn()
    _tz = TRAQUERUtil.getTimeZone()

    # Create an row number column so that we can go back to exact location in the source file
    df.sourceRowNumber = 1:nrow(df)

    @info "nrow(df) BEFORE filter[$(nrow(df))]"

    # Group the rows on the analyis ref
    # dfGoupedByAnalysisRef = groupby(df,:analysisRef)

    try

        counter = 1 # for debug

        # for g in dfGoupedByAnalysisRef
           # Get the first row
        #    r = first(g)

        for r in eachrow(df)

            sourceRowNumber = r.sourceRowNumber

            counter += 1 # for debug
            if counter > stopAfterXLines # for debug
              @info "We exit here because it was asked to stop after line[$stopAfterXLines]"
              return # for debug
            end # for debug

            # Check if NIP_PATIENT is missing
            if ismissing(r.patient_ref)
               error("Error at line[$sourceRowNumber], patient_ref is missing")
               continue
            end

            # Check if analysys ref is missing
            if ismissing(r.analysis_ref)
               error("Error at line[$sourceRowNumber], analysis_ref is missing")
               continue
            end


            patientRef = r.patient_ref
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

            # Get a patient
            patient =
                PatientCtrl.retrieveOnePatient(patientRef, encryptionStr, dbconn)

            if ismissing(patient)
               errorMsg = ("Problem at line[$sourceRowNumber]."
               * " Unable to find patient for ref[$patientRef]. "
               * " Maybe a file of stays has not been integrated.")
               @warn errorMsg
               continue
            end

            # Get a stay
            stay = StayCtrl.retrieveOneStayContainingDateTime(patient, requestTime, dbconn)

            if ismissing(stay)
                noStayErrorMsg = (
                "Problem at row[$sourceRowNumber] of dataframe "
                *"(line[$(sourceRowNumber+1)] of xlsx)."
                * " Unable to find a stay for patient.id[$(patient.id)]"
                * " patient.ref[$(patientRef)]"
                * " starting before the date of the analyis request[$requestTime].")
                @warn noStayErrorMsg
                continue
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

        end # `for r in eachrow(df)`

     catch e
        rethrow(e)
     finally
        TRAQUERUtil.closeDBConn(dbconn)
     end

end
