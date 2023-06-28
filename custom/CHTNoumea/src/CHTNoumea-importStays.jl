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

    # Remove leading Os in the patient NIP
    df.NIP = string.(df.NIP)
    df.NIP = replace.(df.NIP, r"^0+" => s"")

    dfGroupedByNIP = groupby(df,:NIP)

    @showprogress pmap(1:length(dfGroupedByNIP)) do i
        Custom.importStays(
            dfGroupedByNIP[i],
            encryptionStr
        )
    end

    nothing

end

function Custom.importStays(
    df::SubDataFrame,
    encryptionStr::AbstractString
)

    dbconn = TRAQUERUtil.openDBConn()
    _tz = TRAQUERUtil.getTimeZone()

    currentRowForDebug::Union{Missing,DataFrameRow} = missing

    try

        for r in eachrow(df)

            currentRowForDebug = r

            unitCodeName = string(r.CODE_UF_LOCA)
            unitName = r.NOM_UF_LOCA
            ref = string(r.NIP)
            firstname = string(r.PRENOM)
            lastname = string(r.NOM)
            birthdate::Date = r.DATE_NAISSANCE |> n -> Date(n,DateFormat("d/m/y"))

            # Hospitalization in/out
            hospitalizationInDateStr = string(r.DATE_ENTREE_SEJOUR)
            hospitalizationInTimeStr = string(r.HEURE_ENTREE_SEJ)
            hospitalizationInTime = TRAQUERUtil.convertStringToZonedDateTime(
                hospitalizationInDateStr,
                hospitalizationInTimeStr,
                _tz
            )
            hospitalizationOutDateStr = passmissing(string)(r.DATE_SORTIE_SEJOUR)
            hospitalizationOutTimeStr = "00:00"
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
            room = passmissing(string)(r.NUMEROT_LIT)

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
                room = room
            )
            StayCtrl.upsert!(stay, dbconn)

        end # `for r in eachrow(df)`

    catch e
        @error "Problem at line " currentRowForDebug
        rethrow(e)
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end

end
