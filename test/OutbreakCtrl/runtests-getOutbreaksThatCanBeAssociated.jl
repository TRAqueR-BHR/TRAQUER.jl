include("../runtests-prerequisite.jl")

@testset "Test OutbreakCtrl.getOutbreaksThatCanBeAssociated" begin

    dbconn = TRAQUERUtil.openDBConn()
    infectiousStatus =
        InfectiousStatus(id = "10f77bc9-a67a-481c-a17b-201789f61a21") |>
        n -> PostgresORM.retrieve_one_entity(n,false,dbconn)

    OutbreakCtrl.getOutbreaksThatCanBeAssociated(
        infectiousStatus,
        dbconn
    )

    TRAQUERUtil.closeDBConn(dbconn)

end
