include("../runtests-prerequisite.jl")

@testset "Test ExposedFunctionCtrl.getFunctions" begin


    appuser =  AppuserCtrl.retrieveAppuser(
        Appuser(email = TRAQUERUtil.getAdminEmail()),
        true, #includeVectorProps::Bool
    )

    dbconn = TRAQUERUtil.openDBConn()

    fcts = ExposedFunctionCtrl.getFunctions(appuser,dbconn)

    TRAQUERUtil.closeDBConn(dbconn)

end
