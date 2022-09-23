include("../runtests-prerequisite.jl")

@testset "Test OutbreakCtrl.getOutbreakFromInfectiousStatus" begin

    dbconn = TRAQUERUtil.openDBConn()

    OutbreakCtrl.getOutbreakFromInfectiousStatus(
        InfectiousStatus(id = "5dd84d26-5ff5-413c-84a3-a8b883b64042"),
        true,
        dbconn
    )

    TRAQUERUtil.closeDBConn(dbconn)

end
