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


@testset "Test OutbreakCtrl.generateDefaultOutbreakUnitAssos for one infectiousStatus" begin

    dbconn = TRAQUERUtil.openDBConn()

    Outbreak = PostgresORM.retrieve_one_entity(
        Outbreak(id = "520ab98c-e7e1-4289-ab69-21b2f7c2a605"), false, dbconn)

    carrierInfectiousStatus = PostgresORM.retrieve_one_entity(
        InfectiousStatus(id = "bdfe56c6-c47a-4e3e-b980-58ce65738a99"), false, dbconn
    )

    OutbreakCtrl.generateDefaultOutbreakUnitAssos(
        Outbreak,
        carrierInfectiousStatus,
        false , # simulate::Bool,
        dbconn
    )

    TRAQUERUtil.closeDBConn(dbconn)

end

@testset "Test OutbreakCtrl.generateDefaultOutbreakUnitAssos for the whole outbreak" begin

    dbconn = TRAQUERUtil.openDBConn()

    outbreak = PostgresORM.retrieve_one_entity(
        Outbreak(name = "outbreak patient2"), false, dbconn)

    OutbreakCtrl.generateDefaultOutbreakUnitAssos(
        outbreak,
        false , # simulate::Bool,
        dbconn
        ;cleanExisting = true
    )

    TRAQUERUtil.closeDBConn(dbconn)

end
