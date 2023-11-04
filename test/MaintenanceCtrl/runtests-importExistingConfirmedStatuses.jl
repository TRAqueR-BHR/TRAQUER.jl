include("../runtests-prerequisite.jl")

@testset "Test MaintenanceCtrl.importExistingConfirmedStatuses" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        MaintenanceCtrl.importExistingConfirmedStatuses(
            joinpath(
                TRAQUERUtil.getPendingInputFilesDir(),
                "tmp/existing-confirmed-infectious-status.xlsx"
            ),
            cryptStr,
            dbconn
        )
    end
end
