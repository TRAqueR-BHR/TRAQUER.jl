function Custom.importStays(df::DataFrame,
                             encryptionStr::String
                            ;randomData::Bool = false)

    @info (
          "\n# ################################## #"
        * "\n# Starting the integration of stays #"
        * "\n# ################################## #"
        )

    dbconn = TRAQUERUtil.openDBConn()
    _tz = TRAQUERUtil.getTimezone()

    counter = 0 # for debug
    try

        for r in eachrow(df)

            counter += 1 # for debug
            @info "Treating line[$counter] of stays"
            # if counter > 10 # for debug
            #   TRAQUERUtil.commitDBTransaction(dbconn)
            #   return # for debug
            # end # for debug

            unitCodeName = string(r.unit_code_name)
            unitName = r.unit_name
            ref = string(r.patient_ref)
            firstname = string(r.firstname)
            lastname = string(r.lastname)
            birthdate::Date = r.birthdate

            inTime =  ZonedDateTime(r.unit_in_time, getTimezone())
            outTime =  passmissing(ZonedDateTime)(r.unit_out_time, getTimezone())

            hospitalizationInTime =  ZonedDateTime(r.hospitalization_in_time, getTimezone())
            hospitalizationOutTime =  passmissing(ZonedDateTime)(
                r.hospitalization_out_time, getTimezone()
            )

            room = passmissing(string)(r.room)

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
            stay = StayCtrl.createStayIfNotExists(
                patient,
                unit,
                inTime,
                outTime,
                hospitalizationInTime,
                hospitalizationOutTime,
                room,
                dbconn)


        end # `for r in eachrow(df)`

     catch e
        @error "Problem at line $counter"
        rethrow(e)
     finally
        TRAQUERUtil.closeDBConn(dbconn)
     end

end
