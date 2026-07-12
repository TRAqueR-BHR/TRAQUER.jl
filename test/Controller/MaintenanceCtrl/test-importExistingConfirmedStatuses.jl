include("__prerequisite.jl")
@testset "Test MaintenanceCtrl.importExistingConfirmedStatuses" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        MaintenanceCtrl.importExistingConfirmedStatuses(
            joinpath(
                TRAQUERUtil.getFSPendingInputFilesDir(),
                "tmp/existing-confirmed-infectious-status.xlsx"
            ),
            cryptStr,
            dbconn
        )
    end
end
