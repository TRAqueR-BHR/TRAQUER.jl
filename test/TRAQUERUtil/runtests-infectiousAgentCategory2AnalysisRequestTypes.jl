include("../runtests-prerequisite.jl")

@testset "Test TRAQUERUtil.infectiousAgentCategory2AnalysisRequestTypes" begin

    TRAQUERUtil.infectiousAgentCategory2AnalysisRequestTypes(
        InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae
    )

end
