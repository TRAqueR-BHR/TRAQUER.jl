function Custom.importAnalyses(
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


            patientRef = passmissing(string)(r.patient_ref)
            analysisRef = passmissing(string)(r.analysis_ref)
            requestTime = ZonedDateTime(r.request_time,_tz)
            resultTime = ZonedDateTime(r.result_time,_tz)
            sample = passmissing(string)(r.sample) |>
               n -> TRAQUERUtil.string2enum(SAMPLE_MATERIAL_TYPE, n)
            requestType = passmissing(string)(r.request_type) |>
               n -> TRAQUERUtil.string2enum(ANALYSIS_REQUEST_TYPE, n)
            result = passmissing(string)(r.result) |>
               n -> TRAQUERUtil.string2enum(ANALYSIS_RESULT_VALUE_TYPE, n)

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
