function Custom.importAnalyses(encryptionStr::AbstractString)
   pendingFiles = glob("inlog-from-*.csv",TRAQUERUtil.getPendingInputFilesDir())
   Custom.importAnalyses.(
      pendingFiles,
      encryptionStr
   )
end

function Custom.importAnalyses(
   csvFilepath::AbstractString,
   encryptionStr::AbstractString
   ;maxNumberOfLinesToIntegrate::Union{Integer,Missing} = missing,
   rangeToIntegrate::Union{UnitRange{<:Integer},Missing} = missing,
   moveFileToDoneDir::Bool = true
)

   # Concatenate the pending dir to the path if user passed a file name instead of a file path
   if !contains(csvFilepath, Base.Filesystem.path_separator)
      csvFilepath = joinpath(TRAQUERUtil.getPendingInputFilesDir(),csvFilepath)
   end

   # Create a directory for storing the problems of this file
   srcFileBasename = basename(csvFilepath)
   problemsDir = joinpath(TRAQUERUtil.getInputFilesProblemsDir(),srcFileBasename)
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

   # Limit to a range if any
   if !ismissing(rangeToIntegrate)
      rangeToIntegrate = rangeToIntegrate .- 1
      @info rangeToIntegrate
      dfAnalyses = dfAnalyses[rangeToIntegrate,:]
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

   # Move the input file to the DONE dir
   if moveFileToDoneDir
      TRAQUERUtil.moveAnalysesInputFileToDoneDir(csvFilepath)
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

   # Create an analysis ref. column
   df.analysis_ref = map(
      (D_CODE_COMPLET, ANA_CODE) -> begin
              "$(string(D_CODE_COMPLET))_$(ANA_CODE)"
          end,
      df[:,:D_CODE_COMPLET],df[:,:ANA_CODE]
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

         # Check if NIP_PATIENT is missing or empty.
         # This can happen because some test NIPs are 0s only and we removed the 0s in the
         # calling function
         if ismissing(r.NIP_PATIENT) || isempty(r.NIP_PATIENT)
            continue
         end

         # Check if analysys ref is missing
         if ismissing(r.analysis_ref)
            continue
         end

         patientRef = passmissing(String)(r.NIP_PATIENT)
         patientLastname = passmissing(String)(r.NOM) |>
            n -> if ismissing(n) "Non renseigné" else n end
         patientFirstname = passmissing(String)(r.NOM) |>
            n -> if ismissing(n) "Non renseigné" else n end
         patientBirthdate::Date = r.DATE_NAISSANCE |> n -> Date(n,DateFormat("d/m/y"))
         analysisRef = String(r.analysis_ref)
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

         # If cannot find a patient
         # NOTE: We may not have a patient in the case where the analysis is done at the
         #       request of  another hospital.
         #       In that case the NIP is not a NIP of the CHT which poses a challenge to
         #       associate this analysis (and potentially, an infectious status) to the
         #       right patient in case of a hospitalization at the CHT
         patient = PatientCtrl.createPatientIfNoExist(
            patientFirstname,
            patientLastname,
            patientBirthdate,
            patientRef,
            encryptionStr,
            dbconn
         )

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
