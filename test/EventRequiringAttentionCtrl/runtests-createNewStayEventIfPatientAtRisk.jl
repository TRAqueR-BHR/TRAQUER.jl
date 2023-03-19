include("../runtests-prerequisite.jl")

@testset "Test EventRequiringAttentionCtrl.createNewStayEventIfPatientAtRisk" begin


    dbconn = TRAQUERUtil.openDBConn()

    stay = PostgresORM.retrieve_one_entity(
        Stay(id = "ff4cac04-2b34-4ebf-8d09-4f25e13f07b9"),
        false,
        dbconn
    )

    EventRequiringAttentionCtrl.createNewStayEventIfPatientAtRisk(stay, dbconn)

    TRAQUERUtil.closeDBConn(dbconn)


end
