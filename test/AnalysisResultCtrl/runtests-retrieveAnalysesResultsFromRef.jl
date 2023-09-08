include("../runtests-prerequisite.jl")

@testset "Test AnalysisResultCtrl.retrieveAnalysesResultsFromRef" begin

    dbconn = TRAQUERUtil.openDBConn()
    patient = getRandomPatient(dbconn)
    AnalysisResultCtrl.retrieveAnalysesResultsFromRef(
        patient, # patient::Patient,
        "12345", # ref::AbstractString,
        getDefaultEncryptionStr(), # encryptionStr::AbstractString,
        dbconn
    )
    TRAQUERUtil.closeDBConn(dbconn)

end
