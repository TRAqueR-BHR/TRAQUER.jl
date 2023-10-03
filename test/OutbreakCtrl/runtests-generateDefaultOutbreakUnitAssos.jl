include("../runtests-prerequisite.jl")

@testset "Test OutbreakCtrl.generateDefaultOutbreakUnitAssos for one infectiousStatus" begin

    dbconn = TRAQUERUtil.openDBConn()

    outbreak = PostgresORM.retrieve_one_entity(
        Outbreak(id = "fa1d6606-821d-450e-ae17-84ed4fa7fff5"), false, dbconn)

    carrierInfectiousStatus = PostgresORM.retrieve_one_entity(
        InfectiousStatus(id = "9af0ef4d-0b55-480a-b6ca-f56e8f7c2700"), false, dbconn
    )

    OutbreakCtrl.generateDefaultOutbreakUnitAssos(
        outbreak,
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
