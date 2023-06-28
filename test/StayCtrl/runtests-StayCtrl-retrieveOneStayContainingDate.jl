include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.retrieveOneStayContainingDateTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn

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
            inTime = now(getTimeZone()) - Day(2), # inTime::ZonedDateTime,
            outTime = now(getTimeZone()) + Day(2), # outTime::Union{Missing,ZonedDateTime},
            hospitalizationInTime = now(getTimeZone()) - Day(2), # hospitalizationInTime::Date,
            hospitalizationOutTime = missing, # hospitalizationOutTime::Date,
        )
        stay = StayCtrl.upsert!(stay, dbconn)

        stayFound = StayCtrl.retrieveOneStayContainingDateTime(
            patient, now(getTimeZone()), dbconn
        )

        @test stay.id == stayFound.id

        PostgresORM.delete_entity(stay, dbconn)
        PostgresORM.delete_entity(patient, dbconn)
        PostgresORM.delete_entity(unit, dbconn)

    end

end
