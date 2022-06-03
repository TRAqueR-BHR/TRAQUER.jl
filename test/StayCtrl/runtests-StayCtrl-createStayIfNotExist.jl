include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.createStayIfNotExists" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

        unit = UnitCtrl.createUnitIfNotExists(
            randstring(6), # unitCodeName::String,
            randstring(6), # unitName::String,
            dbconn)

        patient = PatientCtrl.createPatientIfNoExist(
            randstring(6), # firstname
            randstring(6), # lastname
            Date("1978-09-12"),
            rand(Int32) |> abs |> string, # hospital ref
            getDefaultEncryptionStr(),
            dbconn)

        stay = StayCtrl.createStayIfNotExists(
            patient,
            unit,
            now(getTimezone()), # inTime::ZonedDateTime,
            now(getTimezone()), # outTime::Union{Missing,ZonedDateTime},
            now(getTimezone()), # hospitalizationInTime::ZonedDateTime,
            now(getTimezone()), # hospitalizationOutTime::Union{Missing,ZonedDateTime},
            dbconn)

        PostgresORM.delete_entity(stay, dbconn)
        PostgresORM.delete_entity(patient, dbconn)
        PostgresORM.delete_entity(unit, dbconn)

    end

end
