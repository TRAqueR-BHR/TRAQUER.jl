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

            # Look for an existing infectious status if any
            infectiousStatusFilter = InfectiousStatus(
                patient = result.patient,
                infectiousAgent = infectiousAgent,
                infectiousStatus = InfectiousStatusType.carrier,
                refTime = result.requestTime
            )

            existingInfectiousStatus = PostgresORM.retrieve_one_entity(
                infectiousStatusFilter, false, dbconn)

            if ismissing(existingInfectiousStatus)
                newInfectiousStatus = infectiousStatusFilter
                PostgresORM.create_entity!(newInfectiousStatus,dbconn)
            end

        end

    catch e
        rethrow(e)
    end

end

function InfectiousStatusCtrl.generateCarrierStatusesForEPC(
    startDate::Date, dbconn::LibPQ.Connection
)

    queryString = "
        SELECT ar.*
        FROM analysis_result ar
        INNER JOIN patient p
          ON p.id  = ar.patient_id
        INNER JOIN stay s
          on ar.stay_id = s.id
        WHERE ar.request_type = ANY(\$1)
        AND ar.result = ANY(\$2)
        AND s.in_time >= \$3"

    queryArgs  = [
        [
            AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae,
            AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae,
            # AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus,
            # AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus,
        ],
        [
            AnalysisResultValueType.positive,
        ],
        startDate
    ]

    try
        analysesResults = PostgresORM.execute_query_and_handle_result(
            queryString,
            AnalysisResult,
            queryArgs,
            false, # complex props
            dbconn)

        for result in analysesResults

            infectiousStatusFilter = InfectiousStatus(
                patient = result.patient,
                infectiousAgent = InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
                infectiousStatus = InfectiousStatusType.carrier,
                refTime = result.requestTime
            )

            existingInfectiousStatus = PostgresORM.retrieve_one_entity(
                infectiousStatusFilter, false, dbconn)

            if ismissing(existingInfectiousStatus)
                PostgresORM.create_entity!(infectiousStatusFilter,dbconn)
            end

        end

    catch e
        rethrow(e)
    end

end
