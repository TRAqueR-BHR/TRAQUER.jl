function InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
    patient::Patient,
    forAnalysesRequestsBetween::Tuple{ZonedDateTime, ZonedDateTime},
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
        x -> x.infectiousStatus ∈ [
                InfectiousStatusType.carrier,
                InfectiousStatusType.suspicion,
                InfectiousStatusType.contact
            ],
        allInfectiousStatuses
    ) |> n -> getproperty.(n,:infectiousAgent) |> unique

    for agent in infectiousAgentsForCarrierOrContactStatuses

        infectiousStatus::Union{Missing,InfectiousStatus} = Custom.checkIfNotAtRiskAnymore(
            allInfectiousStatuses,
            analysesResults,
            agent
        )

        if (
            !ismissing(infectiousStatus)
            && infectiousStatus.infectiousStatus == InfectiousStatusType.not_at_risk
        )

            infectiousStatus.isConfirmed = false # Will be overwritten if exising infectious status

            # Upsert
            infectiousStatus.patient = patient
            InfectiousStatusCtrl.upsert!(
                infectiousStatus,
                dbconn
                ;preserveIsConfirmedPropertyOfExisting = true
            )

            # As always, refresh the current status of the patient
            InfectiousStatusCtrl.updateCurrentStatus(patient, dbconn)

        end

    end

end



function InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
    dbconn::LibPQ.Connection
)

    patients = "
        SELECT p.*
        FROM infectious_status ist
        JOIN patient p
        ON ist.patient_id = p.id
        WHERE ist.infectious_status = 'carrier'" |>
        n -> PostgresORM.execute_query_and_handle_result(n, Patient, missing, false, dbconn)

    forAnalysesRequestsBetween = (
        ZonedDateTime(DateTime("1970-01-01"), TRAQUERUtil.getTimeZone()),
        now(TRAQUERUtil.getTimeZone())
    )

    for patient in patients
        InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
            patient,
            forAnalysesRequestsBetween,
            dbconn
        )
    end

end
