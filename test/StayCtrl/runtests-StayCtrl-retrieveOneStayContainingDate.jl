include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.retrieveOneStayContainingDateTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn

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
            now(getTimezone()) - Day(2), # inTime::ZonedDateTime,
            now(getTimezone()) + Day(2), # outTime::Union{Missing,ZonedDateTime},
            now(getTimezone()) - Day(2), # hospitalizationInTime::Date,
            missing, # hospitalizationOutTime::Date,
            dbconn)

        stayFound = StayCtrl.retrieveOneStayContainingDateTime(
            patient, now(getTimezone()), dbconn)

        @test stay.id == stayFound.id

        PostgresORM.delete_entity(stay, dbconn)
        PostgresORM.delete_entity(patient, dbconn)
        PostgresORM.delete_entity(unit, dbconn)

    end

end
