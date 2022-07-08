include("../runtests-prerequisite.jl")

@testset "Test InfectiousStatusCtrl.defaultCheckIfNotAtRiskAnymore" begin

    # Declare some infectious statuses
    carbaT1Carrier = InfectiousStatus(
            id = "carba T1 carrier",
            infectiousAgent = InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
            infectiousStatus = InfectiousStatusType.carrier,
            refTime = ZonedDateTime(DateTime("2022-03-22T11:00:00"),TRAQUERUtil.getTimezone()),
            isConfirmed = false
    )

    carbaT2Contact = InfectiousStatus(
        id = "carba T2 contact",
        infectiousAgent = InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
        infectiousStatus = InfectiousStatusType.contact,
        refTime = ZonedDateTime(DateTime("2022-03-22T11:50:00"),TRAQUERUtil.getTimezone()),
        isConfirmed = false
    )

    vancoT3Carrier = InfectiousStatus(
        id = "vanco T3 carrier",
        infectiousAgent = InfectiousAgentCategory.vancomycin_resistant_enterococcus,
        infectiousStatus = InfectiousStatusType.carrier,
        refTime = ZonedDateTime(DateTime("2022-03-22T12:00:00"),TRAQUERUtil.getTimezone()),
        isConfirmed = true
    )

    # Declare some analyses
    analysisCarbaT1Neg = AnalysisResult(
        requestTime = ZonedDateTime(DateTime("2022-03-23T10:00:00"),TRAQUERUtil.getTimezone()),
        requestType = AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae,
        result = AnalysisResultValueType.negative
    )

    analysisCarbaT2Neg = AnalysisResult(
        requestTime = ZonedDateTime(DateTime("2022-03-23T10:05:00"),TRAQUERUtil.getTimezone()),
        requestType = AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae,
        result = AnalysisResultValueType.negative
    )

    # Case
    infectiousStatuses = [
        carbaT1Carrier, carbaT2Contact,vancoT3Carrier
    ]

    analysesResults = [
        analysisCarbaT1Neg, analysisCarbaT2Neg
    ]

    InfectiousStatusCtrl.defaultCheckIfNotAtRiskAnymore(
        infectiousStatuses,
        analysesResults,
        InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae
    )

end
