include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getCarriersStaysForListing" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        asso = PostgresORM.retrieve_one_entity(
            OutbreakConfigUnitAsso(id = "95254bd6-d3ac-443e-b37d-dd2151aef7d1"),
            false,
            dbconn
        )
        StayCtrl.getCarriersStaysForListing(
            asso,
            Main.getDefaultEncryptionStr(),
            dbconn
        )
    end

end
