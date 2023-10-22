include("../runtests-prerequisite.jl")

@testset "Test ExposedFunctionCtrl.execute" begin

    appuser =  AppuserCtrl.retrieveAppuser(
        Appuser(email = TRAQUERUtil.getAdminEmail()),
        true, #includeVectorProps::Bool
    )

    exposedFunction = ExposedFunction(
        prettyName = "TRAQUER.greet",
        juliaName = "TRAQUER.greet",
    )

    arguments = [
        ExposedFunctionArgument(rank = 1, value = "Bob", juliaTypeName = "String")
    ]
    dbconn = openDBConn()

    ExposedFunctionCtrl.execute(
        exposedFunction,
        arguments,
        appuser,
        getDefaultEncryptionStr(),
        dbconn
    )

    closeDBConn(dbconn)

end
