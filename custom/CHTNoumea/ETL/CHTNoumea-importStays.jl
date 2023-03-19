function Custom.importStays(df::DataFrame,
                             encryptionStr::String
                            ;randomData::Bool = false)

    dbconn = TRAQUERUtil.openDBConn()
    _tz = TRAQUERUtil.getTimeZone()

    counter = 0 # for debug
    try

        for r in eachrow(df)

           counter += 1 # for debug
           @info "Treating line[$counter] of stays"
           # if counter > 10 # for debug
           #   TRAQUERUtil.commitDBTransaction(dbconn)
           #   return # for debug
           # end # for debug

           unitCodeName = string(r.CODE_UF_LOCA)
           unitName = r.NOM_UF_LOCA
           ref = string(r.NIP)
           if randomData
                firstname = string(r.RANDOM_PRENOM)
                lastname = string(r.RANDOM_NOM)
                birthdateAsStr = r.RANDOM_DATE_NAISSANCE
           else
                firstname = string(r.PRENOM)
                lastname = string(r.NOM)
                birthdateAsStr = r.DATE_NAISSANCE
           end
           birthdate = Date(birthdateAsStr,DateFormat("d/m/y"))
           hospitalizationDateStr = r.DATE_ENTREE_SEJOUR
           hospitalizationDate = Date(hospitalizationDateStr,DateFormat("d/m/y"))
           inDateAsStr = string(r.DATE_ENTREE_MVT)
           inTimeAsStr =string(r.HEURE_ENT_MVT)
           inTime =
             TRAQUERUtil.convertStringToZonedDateTime(inDateAsStr,
                                                      inTimeAsStr,
                                                      _tz)
           outDateAsStr = passmissing(string)(r.DATE_SORTIE_MVT)
           outTimeAsStr = passmissing(string)(r.HEURE_SOR_MVT)
           outTime =passmissing(TRAQUERUtil.convertStringToZonedDateTime)(
               outDateAsStr,
               outTimeAsStr,
               _tz)

           # Get a unit
           unit = UnitCtrl.createUnitIfNotExists(unitCodeName,unitName,dbconn)

           # Get a patient
           patient =
            PatientCtrl.createPatientIfNoExist(firstname,
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
           stay = StayCtrl.upsert!(patient, unit,
                                                inTime,
                                                outTime,
                                                hospitalizationDate,
                                                dbconn)


        end # `for r in eachrow(df)`

     catch e
        @error "Problem at line $counter"
        rethrow(e)
     finally
        TRAQUERUtil.closeDBConn(dbconn)
     end

end
