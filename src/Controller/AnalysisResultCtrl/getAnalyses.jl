function AnalysisResultCtrl.getAnalyses(patient::Patient,dbconn::LibPQ.Connection)

    analyses::Vector{AnalysisResult} = PostgresORM.retrieve_entity(
        AnalysisResult(patient = patient), true, dbconn
    )
    sort!(analyses, by = x -> x.requestTime, rev = true)

    for analysis in analyses
        if !ismissing(analysis.stay)
            analysis.stay.unit = PostgresORM.retrieve_one_entity(analysis.stay.unit,false,dbconn)
        end
    end

    return analyses

end
