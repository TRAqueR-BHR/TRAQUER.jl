include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getCarriersStays" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.getCarriersStays(
            OutbreakUnitAsso(id = "d5c0f714-b2bd-406b-b902-5cf20dacf06c"),
            dbconn
        )
    end

end
