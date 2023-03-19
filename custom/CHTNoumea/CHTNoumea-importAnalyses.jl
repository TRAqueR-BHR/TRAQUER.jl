function Custom.importAnalyses(
    df::DataFrame,
    encryptionStr::String
    ;stopAfterXLines::Number = Inf64)

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
              continue
            end

            patientRef = string(r.patient_ref)
            analysisRef = string(r.analysis_ref)
            requestTime = ZonedDateTime(r.request_time,_tz)
            resultTime = ZonedDateTime(r.result_time,_tz)
            sample = r.sample |> n -> TRAQUERUtil.string2enum(SAMPLE_MATERIAL_TYPE, n)
            requestType = r.request_type |> n -> TRAQUERUtil.string2enum(ANALYSIS_REQUEST_TYPE, n)
            result = r.result |> n -> TRAQUERUtil.string2enum(ANALYSIS_RESULT_VALUE_TYPE, n)

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
                "Problem at line[$sourceRowNumber]."
                * " Unable to find a stay for patient.id[$(patient.id)]"
                * " patient.ref[$(patientRef)]"
                * " starting before the date of the analyis request[$requestDate].")
                @warn noStayErrorMsg
                continue
            end

            analysis = AnalysisResultCtrl.createAnalysisResultIfNotExist(
                patient,
                stay,
                requestType,
                requestTime,
                analysisRef,
                encryptionStr,
                sample,
                result,
                resultTime,
                dbconn)

        end # `for r in eachrow(df)`

     catch e
        rethrow(e)
     finally
        TRAQUERUtil.closeDBConn(dbconn)
     end

end
