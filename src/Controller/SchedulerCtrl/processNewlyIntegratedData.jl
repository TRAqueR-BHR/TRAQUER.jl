function SchedulerCtrl.processNewlyIntegratedData(
    dbconn::LibPQ.Connection
    # Allows to do as if we were at a given time
    ;forceProcessingTime::ZonedDateTime = Union{Missing,TRAQUERUtil.nowInTargetTimeZone()}
)

    # ################################################################################ #
    # Get the ids that we are about to process for tables `analysis_result` and `stay` #
    # ################################################################################ #
    newStaysQueryStr = missing
    newStaysQueryParams = missing
    newAnalysesQueryStr = missing
    newAnalysesQueryParams = missing

    if ismissing(forceProcessingTime)
        newStaysQueryStr = "
            SELECT *
            FROM stay
            WHERE sys_processing_time IS NULL"
        newStaysQueryParams = missing

        newAnalysesQueryStr = "
            SELECT *
            FROM analysis_result
            WHERE sys_processing_time IS NULL"
        newAnalysesQueryParams = missing
    else
        newStaysQueryStr = "
            SELECT *
            FROM stay
            WHERE sys_processing_time IS NULL
            AND (
                (out_time IS NULL AND in_time <= \$1)
                OR out_time <= \$1
            )"
        newStaysQueryParams = [forceProcessingTime]

        newAnalysesQueryStr = "
          SELECT *
          FROM analysis_result
          WHERE sys_processing_time IS NULL
            AND (
                (result_time IS NULL AND request_time <= \$1)
                OR result_time <= \$1
            )"
        newAnalysesQueryParams = [forceProcessingTime]
    end

    newStays = PostgresORM.execute_query_and_handle_result(
        newStaysQueryStr, Stay, newStaysQueryParams, false, dbconn
    )
    newAnalyses = PostgresORM.execute_query_and_handle_result(
        newAnalysesQueryStr, AnalysisResult, newAnalysesQueryParams, false, dbconn
    )

    @info forceProcessingTime
    @info "Processing $(length(newStays)) new stays, $(length(newAnalyses)) new analyses"

    aLongTimeAgo = Date("1970-01-01")
    tomorrow = today() + Day(1)

    # ############################################ #
    # Process new data to deduce the carrier cases #
    # ############################################ #
    patientsWithNewDataInAnalysisTable = getproperty.(newAnalyses, :patient) |> n -> unique(x -> x.id, n)
    for patient in patientsWithNewDataInAnalysisTable

        @info "Patient with new data " getproperty.(patientsWithNewDataInAnalysisTable,:id)

        InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses(
            patient,
            (aLongTimeAgo, tomorrow), # forAnalysesRequestsBetween::Tuple{Date,Date},
            dbconn
        )

    end

    # ############################################ #
    # Process new data to deduce the contact cases #
    # ############################################ #
    # TODO: Restrict the instances of OutbreakUnitAsso to the ones that are involved in the
    #       new activity : the OubreakUnitAssos where the units had movements
    ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(dbconn)

    # ################################################### #
    # Process new data to deduce the not at risk statuses #
    # ################################################### #
    # patientsWithNewDataInAnalysisTable = getproperty.(newAnalyses, :patient) |> n -> unique(x -> x.id, n)
    # for patient in patientsWithNewDataInAnalysisTable

    #     InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
    #         patient,
    #         (aLongTimeAgo, tomorrow), # forAnalysesRequestsBetween::Tuple{Date,Date},
    #         dbconn
    #     )

    # end

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

    # ###################################### #
    # Flag the rows that have been processed #
    # ###################################### #
    processingTime = if ismissing(forceProcessingTime)
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



end
