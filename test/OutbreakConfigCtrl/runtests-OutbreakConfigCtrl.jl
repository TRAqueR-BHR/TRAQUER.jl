include("../runtests-prerequisite.jl")

@testset "Test OutbreakConfigCtrl.generateDefaultOutbreakConfigUnitAssos for one infectiousStatus" begin

    dbconn = TRAQUERUtil.openDBConn()

    outbreakConfig = PostgresORM.retrieve_one_entity(
        OutbreakConfig(id = "520ab98c-e7e1-4289-ab69-21b2f7c2a605"), false, dbconn)

    carrierInfectiousStatus = PostgresORM.retrieve_one_entity(
        InfectiousStatus(id = "bdfe56c6-c47a-4e3e-b980-58ce65738a99"), false, dbconn
    )

    OutbreakConfigCtrl.generateDefaultOutbreakConfigUnitAssos(
        outbreakConfig,
        carrierInfectiousStatus,
        false , # simulate::Bool,
        dbconn
    )

    TRAQUERUtil.closeDBConn(dbconn)

end

@testset "Test OutbreakConfigCtrl.generateDefaultOutbreakConfigUnitAssos for the whole outbreak" begin

    dbconn = TRAQUERUtil.openDBConn()

    outbreak = PostgresORM.retrieve_one_entity(
        Outbreak(name = "outbreak patient2"), false, dbconn)

    OutbreakConfigCtrl.generateDefaultOutbreakConfigUnitAssos(
        outbreak,
        false , # simulate::Bool,
        dbconn
        ;cleanExisting = true
    )

    TRAQUERUtil.closeDBConn(dbconn)

end
