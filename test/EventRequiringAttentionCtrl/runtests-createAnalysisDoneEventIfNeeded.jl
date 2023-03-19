include("../runtests-prerequisite.jl")

@testset "Test EventRequiringAttentionCtrl.createAnalysisDoneEventIfNeeded" begin


    dbconn = TRAQUERUtil.openDBConn()


    patient = PatientCtrl.retrievePatientsFromLastname(
        "O",
        getDefaultEncryptionStr(),
        dbconn) |> first

    analysis = AnalysisResult(
        patient = patient,
        result = AnalysisResultValueType.positive,
        requestType = AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae,
        requestTime = ZonedDateTime(
            DateTime("2022-05-09T17:00:00"),
            TRAQUERUtil.getTimeZone()
        )
    )

    EventRequiringAttentionCtrl.createAnalysisDoneEventIfNeeded(
        analysis,
        dbconn
    )

    TRAQUERUtil.closeDBConn(dbconn)


end
