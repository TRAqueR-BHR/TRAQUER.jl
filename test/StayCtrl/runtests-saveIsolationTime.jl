include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.saveIsolationTime" begin

    # Using patient as argument
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        patient = PostgresORM.retrieve_one_entity(
            Patient(id = "27d45629-1584-4435-9b77-e8e5ba24a793"),
            false,
            dbconn
        )
        StayCtrl.saveIsolationTime(
            patient,
            ZonedDateTime(DateTime("2023-01-04T08:00"),TRAQUERUtil.getTimeZone()),
            dbconn
        )
    end

    # Using event requiring attention as argument
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        patient = PostgresORM.retrieve_one_entity(
            EventRequiringAttention(id = "0d8e2064-ee9f-40da-9e50-3a6686c7cb33"),
            false,
            dbconn
        )
        StayCtrl.saveIsolationTime(
            patient,
            ZonedDateTime(DateTime("2023-01-04T08:30"),TRAQUERUtil.getTimeZone()),
            dbconn
        )
    end

end
