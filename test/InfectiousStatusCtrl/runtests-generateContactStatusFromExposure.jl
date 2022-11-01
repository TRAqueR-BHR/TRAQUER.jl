include("../runtests-prerequisite.jl")

@testset "Test InfectiousStatusCtrl.generateContactStatusFromExposure" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        exposure = ContactExposure(id = "39c3f79c-c93d-464b-9529-28f51bfe6453")
        InfectiousStatusCtrl.generateContactStatusFromExposure(
            exposure,
            dbconn)
    end

end
