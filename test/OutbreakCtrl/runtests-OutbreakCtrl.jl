include("../runtests-prerequisite.jl")

@testset "Test OutbreakCtrl.getOutbreakFromEventRequiringAttention" begin

    dbconn = TRAQUERUtil.openDBConn()
    eventRequiringAttention =
        EventRequiringAttention(id = "f2080700-e036-4482-aa3b-956073f1b2fb") |>
        n -> PostgresORM.retrieve_one_entity(n,false,dbconn)

    OutbreakCtrl.getOutbreakFromEventRequiringAttention(
        eventRequiringAttention,
        true,
        dbconn
    )

    TRAQUERUtil.closeDBConn(dbconn)

end
