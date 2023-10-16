include("../runtests-prerequisite.jl")

@testset "Test DeletedInfectiousStatusCtrl.create" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        infectiousStatus = PostgresORM.retrieve_one_entity(
            InfectiousStatus(id = "90231a4d-5107-45c9-9e6b-9697223d2670"),
            false,
            dbconn
        )
        DeletedInfectiousStatusCtrl.create(
            infectiousStatus,
            dbconn
        )
    end

end
