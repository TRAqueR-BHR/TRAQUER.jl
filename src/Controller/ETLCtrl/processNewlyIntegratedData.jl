function ETLCtrl.processNewlyIntegratedData()
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        ETLCtrl.processNewlyIntegratedData(dbconn)
    end
end

function ETLCtrl.processNewlyIntegratedData(
    dbconn::LibPQ.Connection
    # Allows to do as if we were at a given time
    ;forceProcessingTime::Union{Missing,ZonedDateTime} = missing,
    patient::Union{Patient,Missing} = missing
)

    # ################################################################################ #
    # Get the ids that we are about to process for tables `analysis_result` and `stay` #
    # ################################################################################ #
    newStaysQueryStr = missing
    newStaysQueryParams = []
    newAnalysesQueryStr = missing
    newAnalysesQueryParams = []

    newStaysQueryStr = "
        SELECT *
        FROM stay
        WHERE sys_processing_time IS NULL"

    newAnalysesQueryStr = "
        SELECT *
        FROM analysis_result
        WHERE sys_processing_time IS NULL"

    if !ismissing(patient)

        # Stays
        push!(newStaysQueryParams,patient.id)
        newStaysQueryStr *= "
            AND patient_id = \$$(length(newStaysQueryParams))
        "

        # Analyses
        push!(newAnalysesQueryParams,patient.id)
        newAnalysesQueryStr *= "
            AND patient_id = \$$(length(newAnalysesQueryParams))
        "
    end

    if !ismissing(forceProcessingTime)

        # Stays
        push!(newStaysQueryParams,forceProcessingTime)
        newStaysQueryStr *= "
            AND (
                (out_time IS NULL AND in_time <= \$$(length(newStaysQueryParams)))
                OR out_time <= \$$(length(newStaysQueryParams))
            )"

        # Analyses
        push!(newAnalysesQueryParams,forceProcessingTime)
        newAnalysesQueryStr *= "
            AND (
                -- Allows to do as if we didnt know the result when we ask for a processing
                -- time that is after the request time but before the result time
                (result_time IS NULL AND request_time <= \$$(length(newAnalysesQueryParams)))
                OR result_time <= \$$(length(newAnalysesQueryParams))
            )"

    end

    newStays = PostgresORM.execute_query_and_handle_result(
        newStaysQueryStr, Stay, newStaysQueryParams, false, dbconn
    )
    newAnalyses = PostgresORM.execute_query_and_handle_result(
        newAnalysesQueryStr, AnalysisResult, newAnalysesQueryParams, false, dbconn
    )
    patientsWithNewDataInAnalysisTable = getproperty.(newAnalyses, :patient) |> n -> unique(x -> x.id, n)

    @info "Processing $(length(newStays)) new stays, $(length(newAnalyses)) new analyses"

    aLongTimeAgo = ZonedDateTime(
        DateTime("1970-01-01"),
        TRAQUERUtil.getTimeZone()
    )
    tomorrow = now(TRAQUERUtil.getTimeZone()) + Day(1) # The one day is just to have a margin
    timeUpperBound = if ismissing(forceProcessingTime) tomorrow else forceProcessingTime end

    # ############################################ #
    # Process new data to deduce the carrier cases #
    # ############################################ #
    for patient in patientsWithNewDataInAnalysisTable

        # @info "Patient with new data " getproperty.(patientsWithNewDataInAnalysisTable,:id)

        InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses(
            patient,
            (aLongTimeAgo, timeUpperBound), # forAnalysesRequestsBetween::Tuple{Date,Date},
            dbconn
        )

    end

    # ############################################ #
    # Process new data to deduce the contact cases #
    # ############################################ #
    # TODO: Restrict the instances of OutbreakUnitAsso to the ones that are involved in the
    # new activity : the OubreakUnitAssos where the units had movements.
    # We dont need the units where there were analyses, because in the event where there is a
    # positive analysis that generates a new 'carrier' infectious status, that will not
    # generate contact cases because the status needs to be confirmed
    # ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(
    #     dbconn
    #     ;hintOnWhatOutbreakUnitAssosToSelect = newStays
    # )
    OutbreakUnitAssoCtrl.refreshOutbreakUnitAssosAndRefreshContacts(
        dbconn,
        ;hintOnWhatOutbreakUnitAssosToSelect = newStays
    )

    # ################################################### #
    # Process new data to deduce the not at risk statuses #
    # ################################################### #
    # patientsWithNewDataInAnalysisTable = getproperty.(newAnalyses, :patient) |> n -> unique(x -> x.id, n)
    for patient in patientsWithNewDataInAnalysisTable

        InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
            patient,
            (aLongTimeAgo, timeUpperBound), # forAnalysesRequestsBetween::Tuple{Date,Date},
            dbconn
        )

    end

    InfectiousStatusCtrl.generateNotAtRiskStatusForDeadPatient.(
        newStays,
        dbconn
    )

    # If a new stay did not lead to the creation of an infectious status and that the patient
    # is at risk, create an event 'new_stay'. Eg. if a not at risk patient arrives in a unit
    # where there is a carrier, it will create a contact infectious status and its associated
    # 'new_infectious_status' event, we don't want to create a 'new_stay' event
    EventRequiringAttentionCtrl.createNewStayEventIfPatientAtRisk.(
        newStays,
        dbconn
    )

    # If a new analysis with a result did not lead to the creation of an infectious status,
    # create an event 'new_analysis'
    # TODO
    EventRequiringAttentionCtrl.createAnalysisDoneEventIfNeeded.(
        newAnalyses,
        dbconn
    )

    # Events for late analysis request
    AnalysisRequestCtrl.getOverdueAnalysesRequests(dbconn) |>
        n -> EventRequiringAttentionCtrl.createAnalysisLateEvent.(n, dbconn)

    # ###################################### #
    # Flag the rows that have been processed #
    # ###################################### #
    processingTime = if !ismissing(forceProcessingTime)
        forceProcessingTime
    else
        TRAQUERUtil.nowInTargetTimeZone()
    end
    "UPDATE stay SET sys_processing_time = \$1 WHERE id = ANY(\$2)" |>
    n -> PostgresORM.execute_plain_query(
        n,
        [
            processingTime,
            getproperty.(newStays,:id)
        ],
        dbconn)

    "UPDATE analysis_result SET sys_processing_time = \$1 WHERE id = ANY(\$2)" |>
    n -> PostgresORM.execute_plain_query(
        n,
        [
            processingTime,
            getproperty.(newAnalyses,:id)
        ],
        dbconn
    )

    # ###################################### #
    # Update the general max processing time #
    # ###################################### #
    ETLCtrl.updateMaxProcessingTime(dbconn)

    nothing


end
