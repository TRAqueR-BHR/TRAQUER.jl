function SchedulerCtrl.processNewlyIntegratedData(dbconn::LibPQ.Connection)

    # ################################################################################ #
    # Get the ids that we are about to process for tables `analysis_result` and `stay` #
    # ################################################################################ #
    newStays = "SELECT * FROM stay WHERE sys_processing_time IS NULL" |>
        n -> PostgresORM.execute_query_and_handle_result(n, Stay ,missing, false, dbconn)
    newAnalyses = "SELECT * FROM analysis_result WHERE sys_processing_time IS NULL" |>
        n -> PostgresORM.execute_query_and_handle_result(n, AnalysisResult, missing, false, dbconn)

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
    # is at risk, create an event 'new_stay'
    # TODO

    # If a new analysis with a result did not lead to the creation of an infectious status,
    # create an event 'new_analysis'
    # TODO

    # ###################################### #
    # Flag the rows that have been processed #
    # ###################################### #
    "UPDATE stay SET sys_processing_time = \$1 WHERE id = ANY(\$2)" |>
    n -> PostgresORM.execute_plain_query(
        n,
        [
            now(TRAQUERUtil.getTimeZone()),
            getproperty.(newStays,:id)
        ],
        dbconn)

    "UPDATE analysis_result SET sys_processing_time = \$1 WHERE id = ANY(\$2)" |>
    n -> PostgresORM.execute_plain_query(
        n,
        [
            now(TRAQUERUtil.getTimeZone()),
            getproperty.(newAnalyses,:id)
        ],
        dbconn
    )



end
