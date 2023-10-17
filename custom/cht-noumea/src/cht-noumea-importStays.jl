function Custom.importStays(encryptionStr::AbstractString)
    pendingFiles = glob("dxcare-from-*.csv",TRAQUERUtil.getPendingInputFilesDir())
    Custom.importStays.(
        pendingFiles,
        encryptionStr
    )
end

function Custom.importStays(
    csvFilepath::AbstractString,
    encryptionStr::AbstractString
    ;maxNumberOfLinesToIntegrate::Union{Integer,Missing} = missing,
    moveFileToDoneDir::Bool = true
)

    # Concatenate the pending dir to the path if user passed a file name instead of a file path
    if !contains(csvFilepath, Base.Filesystem.path_separator)
        csvFilepath = joinpath(TRAQUERUtil.getPendingInputFilesDir(),csvFilepath)
    end

    @info "Start importing file[$csvFilepath]"

    # Move the file to the temporary processing dir
    processingFilePath = TRAQUERUtil.moveInputFileToProcessingDir(csvFilepath)

    # Create a directory for storing the problems of this file
    srcFileBasename = basename(csvFilepath)
    problemsDir = joinpath(TRAQUERUtil.getInputFilesProblemsDir(),srcFileBasename)
    rm(problemsDir, recursive = true, force = true) # clean if already exists
    mkpath(problemsDir)

    dfStays = if ismissing(maxNumberOfLinesToIntegrate)
       CSV.read(
            open(processingFilePath, StringEncodings.enc"ISO-8859-1"),  # also works if file is UTF8
            DataFrame
            ;delim = ';'
       )
    else
       TRAQUERUtil.readFirstNLinesOfCSVFile(
            processingFilePath,
            maxNumberOfLinesToIntegrate
            ;delim = ";"
       )
    end


    @time dfOfRowsInError = TRAQUER.Custom.importStays(
        dfStays,
        encryptionStr
    )

    # Serialize the rows in error
    if !isempty(dfOfRowsInError)

        ETLCtrl.serializeRowsInError(dfOfRowsInError, processingFilePath, problemsDir)

        @warn (
            "Some errors in source file[$srcFileBasename]. The problematic lines have been"
            *" extracted together with the desciption of the errors in $problemsDir"
        )

    else
        @info "No problem"
    end

    # Move the input file to the DONE dir or back to where it was
    if moveFileToDoneDir
        TRAQUERUtil.moveStaysInputFileToDoneDir(processingFilePath)
    else
        mv(processingFilePath, csvFilepath)
    end

    # Delete the temporary processing dir
    rm(dirname(processingFilePath))

    # Remove the problem directory if there is nothing in it. This allows to only have
    # directories that correspond to integrations that didnt go well
    if isempty(readdir(problemsDir))
        rm(problemsDir)
    end


 end


"""
  - No column for hospitalization out time => use 00:00:00
"""
function Custom.importStays(
    df::DataFrame,
    encryptionStr::AbstractString
)


    @info (
          "\n# ################################## #"
        * "\n# Starting the integration of stays #"
        * "\n# ################################## #"
    )

    # Input file can be empty
    if isempty(df)
        return DataFrame()
    end

    # Remove leading Os in the patient NIP
    df.NIP = string.(df.NIP)
    df.NIP = replace.(df.NIP, r"^0+" => s"")

    # Create a line number column (used in particular to know the lines where we had problems)
    df.lineNumInSrcFile = 2:nrow(df)+1

    dfGroupedByNIP = DataFrames.groupby(df,:NIP)

    dfOfRowsInError = @showprogress pmap(1:length(dfGroupedByNIP)) do i
        Custom.importStays(
            dfGroupedByNIP[i],
            encryptionStr
        )
    end |>
    n -> vcat(n...)

    return dfOfRowsInError

end

function Custom.importStays(
    df::SubDataFrame,
    encryptionStr::AbstractString
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

        for r in eachrow(df)

            # Keep track of the line number in the src CSV file
            lineNumInSrcFile = r.lineNumInSrcFile

            unitCodeName = string(r.CODE_UF_LOCA)
            unitName = r.NOM_UF_LOCA
            ref = string(r.NIP)
            firstname = string(r.PRENOM)
            lastname = string(r.NOM)
            birthdate::Date = r.DATE_NAISSANCE |> n -> Date(n,DateFormat("d/m/y"))

            # Check if NIP_PATIENT is missing or empty.
            # This can happen because some test NIPs are 0s only and we removed the 0s in the
            # calling function
            if ismissing(ref) || isempty(ref)
                continue
            end

            # Ignore consultations
            if contains(r.NOM_UF_LOCA," CS") || contains(r.NOM_UF_LOCA," CS ")
                continue
            end

            # Hospitalization in/out
            hospitalizationInDateStr = string(r.DATE_ENTREE_SEJOUR)
            hospitalizationInTimeStr = string(r.HEURE_ENTREE_SEJ)
            hospitalizationInTime = TRAQUERUtil.convertStringToZonedDateTime(
                hospitalizationInDateStr,
                hospitalizationInTimeStr,
                _tz
            )
            hospitalizationOutDateStr = passmissing(string)(r.DATE_SORTIE_SEJOUR)
            hospitalizationOutTimeStr = string(r.HEURE_SORTIE_SEJOUR)
            hospitalizationOutTime = passmissing(TRAQUERUtil.convertStringToZonedDateTime)(
                hospitalizationOutDateStr,
                hospitalizationOutTimeStr,
                _tz
            )

            # Unit in/out
            inDateStr = string(r.DATE_ENTREE_MVT)
            inTimeStr =string(r.HEURE_ENT_MVT)
            inTime = passmissing(TRAQUERUtil.convertStringToZonedDateTime)(
                inDateStr,
                inTimeStr,
                _tz
            )
            outDateAsStr = passmissing(string)(r.DATE_SORTIE_MVT)
            outTimeAsStr = passmissing(string)(r.HEURE_SOR_MVT)
            outTime = passmissing(TRAQUERUtil.convertStringToZonedDateTime)(
                outDateAsStr,
                outTimeAsStr,
                _tz
            )

            # Room
            room = passmissing(String)(r.NUMEROT_LIT) # String7 -> String

            # Sector
            sector = passmissing(string)(r.NOM_SECTEUR)

            # Out label
            outLabel = passmissing(string)(r.LIB_MODE_SORTIE)
            diedDuringStay::Bool = if (
                !ismissing(outLabel)
                && TRAQUERUtil.rmAccentsAndLowercase(outLabel) === "deces"
            )
                true
            else
                false
            end

            # Get a unit
            unit = UnitCtrl.createUnitIfNotExists(unitCodeName,unitName,dbconn)

            # Get a patient
            patient = PatientCtrl.createPatientIfNoExist(
                firstname,
                lastname,
                birthdate,
                ref,
                encryptionStr,
                dbconn)

            if ismissing(patient)
                error("Unable to find patient for firstname[$firstname]"
                * " lastname[$lastname] birthdate[$birthdateAsStr]."
                * " Maybe a file of checks has not been integrated.")
            end

            # Retrieve the stay
            stay = Stay(
                patient = patient,
                unit = unit,
                inTime = inTime,
                outTime = outTime,
                hospitalizationInTime = hospitalizationInTime,
                hospitalizationOutTime = hospitalizationOutTime,
                hospitalizationOutComment = outLabel,
                room = room,
                sector = sector,
                patientDiedDuringStay = diedDuringStay
            )
            StayCtrl.upsert!(stay, dbconn)

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
