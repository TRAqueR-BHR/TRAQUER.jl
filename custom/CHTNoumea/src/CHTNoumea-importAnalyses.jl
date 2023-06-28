function Custom.importAnalyses(
   csvFilepath::AbstractString,
   problemsDir::String,
   encryptionStr::AbstractString
   ;maxNumberOfLinesToIntegrate::Union{Integer,Missing} = missing
)

   dfAnalyses = CSV.read(
      "/home/traquer/DATA/pending/inlog-3mois.csv",
      DataFrame
      ;delim = ';'
   )

   if !ismissing(maxNumberOfLinesToIntegrate)
      dfAnalyses = first(dfAnalyses,10)
   end

   @time TRAQUER.Custom.importAnalyses(
      dfAnalyses,
      getDefaultEncryptionStr(),
      # "/home/traquer/DATA/problems/dxcare-3mois.csv/",
      "/home/traquer/CODE/TRAQUER.jl/tmp/problems/inlog-3mois.csv/"
   )

end

"""
   - We may have a bacteria culture positive without the ATB2 exam to know what bacteria it is - See NIPs 231943, 57042 (PREPC)
   - We interpret NEPC as positive
   - No column for sample type
   - Use column DATE_SAISIE_RES for the result date (and set time to 00:00:00)
   TODO: * Keep the result string of the source file to be able to check that the source data
         * If culture is positive look for the ATB2 row to get the name of the bacteria
"""
function Custom.importAnalyses(
   df::DataFrame,
   encryptionStr::AbstractString,
   problemsDir::String
)

   @info (
     "\n# #################################### #"
   * "\n# Starting the integration of analyses #"
   * "\n# #################################### #"
   )

   # Remove leading Os in the patient NIP
   df.NIP_PATIENT = string.(df.NIP_PATIENT)
   df.NIP_PATIENT = replace.(df.NIP_PATIENT, r"^0+" => s"")

   # Create a line number column (used in particular to know the lines where we had problems)
   df.lineNumInSrcFile = 1:nrow(df)-1

   # Create an analysis ref column
   df.analysis_ref = map(
      (NIP_PATIENT, ANA_CODE, DATE_DEMANDE, HEURE_DEMANDE) -> begin
              "$(string(NIP_PATIENT))_$(ANA_CODE)_$(DATE_DEMANDE),$(HEURE_DEMANDE)"
          end,
      df[:,:NIP_PATIENT],df[:,:ANA_CODE],df[:,:DATE_DEMANDE],df[:,:HEURE_DEMANDE]
   )

   # Add a column to store the error
   df[!, "error_description"] = Vector{Union{Missing, String}}(fill(missing, size(df, 1)))
   df[!, "error_uuid"] = Vector{Union{Missing, String}}(fill(missing, size(df, 1)))

   # Group the dataframe by patient NIP
   dfGroupedByNIP = groupby(df,:NIP_PATIENT)

   # Process the patients in parrallel and concatenate the rows in error
   dfOfRowsInError = @showprogress pmap(1:length(dfGroupedByNIP)) do i
         Custom.importAnalyses(
            dfGroupedByNIP[i],
            encryptionStr
         )
      end |>
      n -> vcat(n...)

   # Serialize the rows in error
   if !isempty(dfOfRowsInError)
      mkpath(problemsDir)
      filepathForLinesWithProblems = joinpath(problemsDir,string(UUIDs.uuid4(),".csv"))
      @info filepathForLinesWithProblems
      CSV.write(
         filepathForLinesWithProblems,
         select(dfOfRowsInError, Not(["error_description","error_uuid"]))
         ;delim = ";"
      )
      # filepathForLinesWithProblemsREADME = "$filepathForLinesWithProblems.README"
   else
      @info "no problem"
   end

   nothing

end


function Custom.importAnalyses(
   df::SubDataFrame,
   encryptionStr::AbstractString,
)

   dfOfRowsInError = DataFrame()

   dbconn = TRAQUERUtil.openDBConn()
   _tz = TRAQUERUtil.getTimeZone()

   currentRowForDebug::Union{Missing,DataFrameRow} = missing

   try

      for (rowIdx, r) in enumerate(eachrow(df))

           if iseven(rowIdx)
            error("even number")
           end

           sourceRowNumber = r.sourceRowNumber

           currentRowForDebug = r

           # Exclude ATB2 rows, for the moment we dont know what to do with it
           if r.ANA_CODE == "ATB2"
               continue
           end

           # Check if NIP_PATIENT is missing
           if ismissing(r.NIP_PATIENT)
              error("Error at line[$sourceRowNumber], NIP_PATIENT is missing")
              continue
           end

           # Check if analysys ref is missing
           if ismissing(r.analysis_ref)
              error("Error at line[$sourceRowNumber], analysis_ref is missing")
              continue
           end

           patientRef = passmissing(string)(r.NIP_PATIENT)
           analysisRef = passmissing(string)(r.analysis_ref)
           resultRawText = if (
               ismissing(r.Libelle_micro_organisme)
               || strip(r.Libelle_micro_organisme) == "null"
            )
               missing
           else
               strip(r.Libelle_micro_organisme)
           end

           requestTime = TRAQUERUtil.convertStringToZonedDateTime(
               string(r.DATE_DEMANDE),
               string(r.HEURE_DEMANDE),
               _tz
           )

           resultTime = passmissing(TRAQUERUtil.convertStringToZonedDateTime)(
                  passmissing(string)(r.DATE_SAISIE_RES),
                  "00:00",
                  _tz
           )

           sample = missing

           requestType = Custom.convertStringInInputFileToANALYSIS_REQUEST_TYPE(r.ANA_CODE)
           result = passmissing(string)(r.VALEUR_RESULTAT) |>
              n -> passmissing(Custom.convertStringInInputFileToANALYSIS_RESULT_VALUE_TYPE)(n, requestType)

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
               error(noStayErrorMsg)
           end

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
      # @error "Problem at line: " currentRowForDebug
      # rethrow(e)

      errorDescription = TRAQUERUtil.formatExceptionAndStackTraceCore(e, stacktrace(catch_backtrace()))

      # Create a copy of the row and set the error description
      rowInError = deepcopy(currentRowForDebug)
      rowInError.error_description = errorDescription
      rowInError.error_uuid = UUIDs.uuid4() |> string
      push!(dfOfRowsInError,rowInError)
   finally
       TRAQUERUtil.closeDBConn(dbconn)
   end

   return dfOfRowsInError

end
