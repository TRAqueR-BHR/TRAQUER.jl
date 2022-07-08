include("../../../test/runtests-prerequisite.jl")

@testset "Test checkIfNotAtRiskAnymore()" begin

    # An infectious status
    infectiousStatus = InfectiousStatus(
        refTime = ZonedDateTime(now(),getTimezone()),
        infectiousAgent = InfectiousAgentCategory.vancomycin_resistant_enterococcus
    )

    negAnalysisBeforeInfectiousStatus1 = AnalysisResult(
        requestTime = ZonedDateTime(now() - Minute(20),getTimezone()),
        result = AnalysisResultValueType.negative
    )

    negAnalysisAfterInfectiousStatus1 = AnalysisResult(
        requestTime = ZonedDateTime(now() + Minute(1),getTimezone()),
        result = AnalysisResultValueType.negative
    )

    negAnalysisAfterInfectiousStatus2 = AnalysisResult(
        requestTime = ZonedDateTime(now() + Minute(1),getTimezone()),
        result = AnalysisResultValueType.negative
    )

    # CASE `infectiousStatus carrier``
    infectiousStatus.infectiousStatus = InfectiousStatusType.carrier
    analyses = [
        negAnalysisBeforeInfectiousStatus1,
        negAnalysisAfterInfectiousStatus1,
        negAnalysisAfterInfectiousStatus2
    ]

    Custom.checkIfNotAtRiskAnymore(
        infectiousStatus,
        negAnalysisAfterInfectiousStatus2
    )


end
