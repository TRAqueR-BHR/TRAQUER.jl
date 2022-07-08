function InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
    patient::Patient,
    forAnalysesRequestsBetween::Tuple{Date,Date},
    dbconn::LibPQ.Connection
)

    # Get the existing infectious status for this patient
    allInfectiousStatuses = InfectiousStatusCtrl.getInfectiousStatuses(patient, dbconn)

    queryString = "
        SELECT ar.*
        FROM analysis_result ar
        INNER JOIN patient p
          ON p.id  = ar.patient_id
        WHERE p.id = \$1
        AND ar.request_time >= \$2
        AND ar.request_time <= \$3
        "

    queryArgs  = [
        patient.id,
        first(forAnalysesRequestsBetween),
        last(forAnalysesRequestsBetween),
    ]

    analysesResults = PostgresORM.execute_query_and_handle_result(
        queryString,
        AnalysisResult,
        queryArgs,
        false, # complex props
        dbconn
    )

    infectiousAgentsForCarrierOrContactStatuses = filter(
        x -> x.infectiousStatus ∈ [InfectiousStatusType.carrier, InfectiousStatusType.contact],
        allInfectiousStatuses
    ) |> n -> getproperty.(n,:infectiousAgent) |> unique

    for agent in infectiousAgentsForCarrierOrContactStatuses

        infectiousStatus::Union{Missing,InfectiousStatus} = Custom.checkIfNotAtRiskAnymore(
            allInfectiousStatuses,
            analysesResults,
            agent
        )

        if infectiousStatus.infectiousStatus == InfectiousStatusType.not_at_risk

            # Upsert
            infectiousStatus.patient = patient
            InfectiousStatusCtrl.upsert!(infectiousStatus, dbconn)

            # As always, refresh the current status of the patient
            InfectiousStatusCtrl.updateCurrentStatus(patient, dbconn)

        end

    end




end
