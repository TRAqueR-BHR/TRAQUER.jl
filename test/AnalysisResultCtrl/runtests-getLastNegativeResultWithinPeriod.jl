include("../runtests-prerequisite.jl")

@testset "Test AnalysisResultCtrl.getLastNegativeResultWithinPeriod" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        patient = PostgresORM.retrieve_one_entity(
            Patient(id = "2558fabb-9d21-417c-97cf-419875368cf7"),
            false,
            dbconn
        )
        AnalysisResultCtrl.getLastNegativeResultWithinPeriod(
            patient,
            InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
            ZonedDateTime(DateTime("2022-01-11T00:00:00"),TRAQUERUtil.getTimeZone()),
            ZonedDateTime(DateTime("2024-12-01T00:00:00"),TRAQUERUtil.getTimeZone()),
            dbconn
        )
    end

end
