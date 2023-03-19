include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.transformStaysForListing" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        stays = PostgresORM.execute_query_and_handle_result(
            "select * from stay limit 2",
            Stay,
            missing,
            false, # complex props
            dbconn
        )
        StayCtrl.transformStaysForListing(
            stays,
            Main.getDefaultEncryptionStr(),
            dbconn
        )
    end

end
