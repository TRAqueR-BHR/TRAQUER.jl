include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getCarriersStaysForListing" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.getCarriersStaysForListing(
            OutbreakConfigUnitAsso(id = "d5c0f714-b2bd-406b-b902-5cf20dacf06c"),
            Main.getDefaultEncryptionStr(),
            dbconn
        )
    end

end
