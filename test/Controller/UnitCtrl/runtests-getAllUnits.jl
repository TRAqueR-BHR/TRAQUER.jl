include("prerequisite.jl")

@testset "Test UnitCtrl.getAllUnits" begin
    @time TRAQUERUtil.createDBConnAndExecute() do dbconn
        units = UnitCtrl.getAllUnits(
            false, # complex values
            dbconn
        )
    end
end
