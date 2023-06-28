include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.upsert!" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

        unit = UnitCtrl.createUnitIfNotExists(
            randstring(6), # unitCodeName::AbstractString,
            randstring(6), # unitName::AbstractString,
            dbconn)

        patient = PatientCtrl.createPatientIfNoExist(
            randstring(6), # firstname
            randstring(6), # lastname
            Date("1978-09-12"),
            rand(Int32) |> abs |> string, # hospital ref
            getDefaultEncryptionStr(),
            dbconn)

        stay = Stay(
            patient = patient,
            unit = unit,
            inDate = Dates.Date(inTinow(getTimeZone())me),
            now(getTimeZone()), # inTime::ZonedDateTime,
            now(getTimeZone()), # outTime::Union{Missing,ZonedDateTime},
            now(getTimeZone()), # hospitalizationInTime::ZonedDateTime,
            now(getTimeZone()), # hospitalizationOutTime::Union{Missing,ZonedDateTime},
            room = room
        )

        StayCtrl.upsert!(stay, dbconn)

        PostgresORM.delete_entity(stay, dbconn)
        PostgresORM.delete_entity(patient, dbconn)
        PostgresORM.delete_entity(unit, dbconn)

    end

end
