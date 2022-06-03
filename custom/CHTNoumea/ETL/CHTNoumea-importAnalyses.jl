function Custom.importAnalyses(df::DataFrame,
                                encryptionStr::String
                                ;stopAfterXLines::Number = Inf64)

    @info (
      "\n# #################################### #"
    * "\n# Starting the integration of analyses #"
    * "\n# #################################### #"
    )

    dbconn = TRAQUERUtil.openDBConn()
    _tz = TRAQUERUtil.getTimezone()

    # Create an row number column so that we can go back to exact location in the source file
    df.sourceRowNumber = 1:nrow(df)

    # Create an analysis ref column
    df.analysisRef = map(
        (ANA_CODE, D_CODE_COMPLET, NIP_PATIENT) -> begin
                "$(ANA_CODE)_$(D_CODE_COMPLET)_$(string(NIP_PATIENT))"
            end,
        df[:,:ANA_CODE],df[:,:D_CODE_COMPLET],df[:,:NIP_PATIENT]
    )

    @info "nrow(df) BEFORE filter[$(nrow(df))]"
    # Only keep the lignes that corresponds to the analysis of interest
    df = filter(x -> (x.BILAN in ["GXEPCC","PREPC","GXERVC","PRVRE"]
              || (x.BILAN == "ATB2" && !ismissing(x.BMR) && x.BMR in ["EPC","ERV"])),
            df)
    @info "nrow(df) AFTER filter[$(nrow(df))]"

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
           if ismissing(r.NIP_PATIENT)
             continue
           end

           patientRef = string(r.NIP_PATIENT)
           requestDate = if isa(r.DATE_DEMANDE, AbstractString)
                Date(r.DATE_DEMANDE,dateformat"d/m/y")
            else
                ZonedDateTime(r.DATE_DEMANDE,_tz)
            end
           analysisName = r.LIBELLE_ANALYSE
           analysisCodeName = r.ANA_CODE
           sampleType = r.Libelle_nature_prelevement
           result = r.VALEUR_RESULTAT

           if r.BILAN == "ATB2"
             result = join(string.(r.Libelle_micro_organisme, " - ",
                                   r.BMR),", ")
             # result = "$(r.Libelle_micro_organisme) - $(r.BMR)"
             @info "ATB2[$result]"
           end

           analysisRef = r.analysisRef

           # Get a patient
           patient =
             PatientCtrl.retrieveOnePatient(patientRef,
                                            encryptionStr,
                                            dbconn)

           if ismissing(patient)
               errorMsg = ("Problem at line[$sourceRowNumber]."
               * " Unable to find patient for ref[$patientRef]. "
               * " Maybe a file of stays has not been integrated.")
               @warn errorMsg
               continue
           end

           # Get a stay
           stay =
             StayCtrl.retrieveOneStayContainingDateTime(patient,
                                                    requestDate,
                                                    dbconn)
           if ismissing(stay)
                noStayErrorMsg = (
                "Problem at line[$sourceRowNumber]."
                * " Unable to find a stay for patient.id[$(patient.id)]"
                * " patient.ref[$(patientRef)]"
                * " starting before the date of the analyis request[$requestDate].")
                @warn noStayErrorMsg
                continue
           end

           # Get the analysis type
           analysisType =
            AnalysisTypeCtrl.createAnalysisTypeIfNotExist(analysisCodeName,
                                                          analysisName,
                                                          dbconn)



           analysis = AnalysisResultCtrl.createAnalysisResultIfNotExist(patient,
                                                            stay,
                                                            analysisType,
                                                            requestTime,
                                                            analysisRef,
                                                            encryptionStr,
                                                            sampleType,
                                                            result,
                                                            dbconn)

        end # `for r in eachrow(df)`

     catch e
        rethrow(e)
     finally
        TRAQUERUtil.closeDBConn(dbconn)
     end

end
