function Custom.importAnalyses(
   csvFilepath::AbstractString,
   problemsDir::String,
   encryptionStr::AbstractString
   ;maxNumberOfLinesToIntegrate::Union{Integer,Missing} = missing
)

   # Create a directory for storing the problems of this file
   srcFileBasename = basename(csvFilepath)
   problemsDir = joinpath(problemsDir,srcFileBasename)
   rm(problemsDir, recursive = true, force= true) # clean if already exists
   mkpath(problemsDir)

   dfAnalyses = if ismissing(maxNumberOfLinesToIntegrate)
      CSV.read(
         csvFilepath,
         DataFrame
         ;delim = ';'
      )
   else
      TRAQUERUtil.readFirstNLinesOfCSVFile(
         csvFilepath,
         maxNumberOfLinesToIntegrate
         ;delim = ";"
      )
   end


   @time dfOfRowsInError = TRAQUER.Custom.importAnalyses(
      dfAnalyses,
      encryptionStr
   )

   # Serialize the rows in error
   if !isempty(dfOfRowsInError)

      ETLCtrl.serializeRowsInError(dfOfRowsInError, csvFilepath, problemsDir)

      @warn (
         "Some errors in source file[$srcFileBasename]. The problematic lines have been"
         *" extracted together with the desciption of the errors in $problemsDir"
      )

   else
      @info "No problem"
   end

   # Remove the directory if there is nothing in it. This allows to only have directories
   # that correspond to integrations that didnt go well.
   if isempty(readdir(problemsDir))
      rm(problemsDir)
   end

end

"""
   - We ignore ATB2
   - We may have a bacteria culture positive without the ATB2 exam to know what bacteria it is
      (see NIPs 231943, 57042 (PREPC))
   - Also have a ATB2 without the a prior PREPC or PRVE (see NIP 39262667)
   - We interpret NEPC as negative
   - Use column DATE_SAISIE_RES for the result date (and set time to 00:00:00)
   TODO: * Keep the result string of the source file to be able to check that the source data
         * If culture is positive look for the ATB2 row to get the name of the bacteria
"""
function Custom.importAnalyses(
   df::DataFrame,
   encryptionStr::AbstractString
)::DataFrame

   @info (
     "\n# #################################### #"
   * "\n# Starting the integration of analyses #"
   * "\n# #################################### #"
   )

   # Remove leading Os in the patient NIP
   df.NIP_PATIENT = String.(string.(df.NIP_PATIENT))
   df.NIP_PATIENT = replace.(df.NIP_PATIENT, r"^0+" => s"")

   # Create a line number column (used in particular to know the lines where we had problems)
   df.lineNumInSrcFile = 2:nrow(df)+1

   # Create an analysis ref column
   df.analysis_ref = map(
      (NIP_PATIENT, ANA_CODE, BMR, DATE_DEMANDE, HEURE_DEMANDE) -> begin
              "$(string(NIP_PATIENT))_$(ANA_CODE)_BMR-$(BMR)_$(DATE_DEMANDE)_$(HEURE_DEMANDE)"
          end,
      df[:,:NIP_PATIENT],df[:,:ANA_CODE],df[:,:BMR],df[:,:DATE_DEMANDE],df[:,:HEURE_DEMANDE]
   )

   # Group the dataframe by patient NIP
   dfGroupedByNIP = DataFrames.groupby(df,:NIP_PATIENT)

   # Process the patients in parrallel and concatenate the rows in error
   dfOfRowsInError = @showprogress pmap(1:length(dfGroupedByNIP)) do i
         Custom.importAnalyses(
            dfGroupedByNIP[i],
            encryptionStr
         )
      end |>
      n -> vcat(n...)

   return dfOfRowsInError

end


function Custom.importAnalyses(
   df::SubDataFrame,
   encryptionStr::AbstractString,
)

   # Create an empty DataFrame for storing problems
   dfOfRowsInError = DataFrame(
      lineNumInSrcFile = Vector{Int}(),
      error = Vector{String}()
   )

   dbconn = TRAQUERUtil.openDBConn()
   _tz = TRAQUERUtil.getTimeZone()

   lineNumInSrcFile = 0

   try

      for (rowIdx, r) in enumerate(eachrow(df))

         # Keep track of the line number in the src CSV file
         lineNumInSrcFile = r.lineNumInSrcFile

         # Check if NIP_PATIENT is missing
         if ismissing(r.NIP_PATIENT)
            error("NIP_PATIENT is missing")
            continue
         end

         # Check if analysys ref is missing
         if ismissing(r.analysis_ref)
            error("analysis_ref is missing")
            continue
         end

         patientRef = passmissing(String)(r.NIP_PATIENT)
         analysisRef = passmissing(String)(r.analysis_ref)
         resultRawText = if (
            ismissing(r.Libelle_micro_organisme)
            || strip(r.Libelle_micro_organisme) == "null"
         )
            missing
         else
            strip(r.Libelle_micro_organisme)
         end

         requestTime = TRAQUERUtil.convertStringToZonedDateTime(
            String(r.DATE_DEMANDE), # String15 -> String
            string(r.HEURE_DEMANDE), # Int64 -> String
            _tz
         )

         resultTime = passmissing(TRAQUERUtil.convertStringToZonedDateTime)(
            passmissing(String)(r.DATE_SAISIE_RES), # String15 -> String
            passmissing(string)(r.HEURE_SAISIE_RES), # Int64 -> String
            _tz
         )

         sample = Custom.Custom.convertETLInputDataToSampleMaterialType(
            passmissing(String)(r.NATURE_CODE)
        )

         tmpRes = Custom.convertETLInputDataToRequestAndResultType(
            passmissing(String)(r.ANA_CODE), # String7 -> String
            passmissing(String)(r.BMR), # String7 -> String
            passmissing(String)(r.VALEUR_RESULTAT) # String15 -> String
         )

         if isnothing(tmpRes)
            continue
         end
         requestType, result = tmpRes

         # Get a patient
         patient =
            PatientCtrl.retrieveOnePatient(patientRef, encryptionStr, dbconn)

         if ismissing(patient)
            errorMsg = (
               "Unable to find patient for ref[$patientRef]. "
            * " Maybe a file of stays has not been integrated.")
            error(errorMsg)
            continue
         end

         # Get a stay.
         # NOTE: We may not find a stay for the analysis, it doesnt matter, we still want to
         #       record the information so that we can deduce the infectious status
         stay = StayCtrl.retrieveOneStayContainingDateTime(patient, requestTime, dbconn)

         analysisResult = AnalysisResult(
            patient = patient,
            stay = stay,
            sampleMaterialType = sample,
            requestTime = requestTime,
            resultTime = resultTime,
            result = result,
            resultRawText = resultRawText,
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
      errorDescription = TRAQUERUtil.formatExceptionAndStackTraceCore(
         e, stacktrace(catch_backtrace())
      )

      push!(
         dfOfRowsInError,
         (
            lineNumInSrcFile = lineNumInSrcFile,
            error = errorDescription
         )
      )
   finally
       TRAQUERUtil.closeDBConn(dbconn)
   end

   return dfOfRowsInError

end
