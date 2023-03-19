include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getCarriersOrContactsStays" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.getCarriersOrContactsStays(
            OutbreakUnitAsso(id = "ef8b5f77-4f8a-458f-b689-1e1fbb0de524"),
            InfectiousStatusType.carrier,
            dbconn
        )
    end

end
