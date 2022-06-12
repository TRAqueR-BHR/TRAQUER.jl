function InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses(
    patient::Patient,
    forAnalysesRequestsBetween::Tuple{Date,Date},
    dbconn::LibPQ.Connection
)

    # Declare the rules for statuses
    rules = Dict(
        # For carbapenemase producing bacteria
        (
            AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae,
            AnalysisResultValueType.positive
        ) => InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
        (
            AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae,
            AnalysisResultValueType.positive
        ) => InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
        # For vancomycin resistant bacterias
        (
            AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus,
            AnalysisResultValueType.positive
        ) => InfectiousAgentCategory.vancomycin_resistant_enterococcus,
        (
            AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus,
            AnalysisResultValueType.positive,
        ) => InfectiousAgentCategory.vancomycin_resistant_enterococcus,
    )


    queryString = "
        SELECT ar.*
        FROM analysis_result ar
        INNER JOIN patient p
          ON p.id  = ar.patient_id
        WHERE p.id = \$1
        AND ar.request_time >= \$2
        AND ar.request_time <= \$3"

    queryArgs  = [
        patient.id,
        first(forAnalysesRequestsBetween),
        last(forAnalysesRequestsBetween),
    ]

    try
        analysesResults = PostgresORM.execute_query_and_handle_result(
            queryString,
            AnalysisResult,
            queryArgs,
            false, # complex props
            dbconn)

        for result in analysesResults

            if !haskey(rules,(result.requestType,result.result))
                return
            end

            # Get the infectious agent corresponding to the request/result tuple
            infectiousAgent = rules[(result.requestType,result.result)]

            # Upsert
            infectiousStatus = InfectiousStatus(
                patient = result.patient,
                infectiousAgent = infectiousAgent,
                infectiousStatus = InfectiousStatusType.carrier,
                refTime = result.requestTime,
                isConfirmed = false,
            )
            InfectiousStatusCtrl.upsert!(infectiousStatus, dbconn)

        end

        # As always, refresh the current status of the patient
        InfectiousStatusCtrl.updateCurrentStatus(patient, dbconn)

    catch e
        rethrow(e)
    end

end
