function InfectiousStatusCtrl.updateCurrentStatus(
    patient::Patient,
    dbconn::LibPQ.Connection)

    queryString = "
        SELECT ist.*
        FROM infectious_status ist
        WHERE ist.patient_id = \$1
        "
    queryArgs = [patient.id]
    statuses = @mock PostgresORM.execute_query_and_handle_result(
        queryString,InfectiousStatus,queryArgs,false,dbconn)
    # return statuses
    statusesGroupedByAgent = SplitApplyCombine.group(x -> x.infectiousAgent, statuses)

    for (infectiousAgent,infectiousStatuses) in pairs(statusesGroupedByAgent)

        # Make latest infectious status first
        sort!(infectiousStatuses, by = x -> x.refTime, rev = true)

        for (i,infectiousStatus) in enumerate(infectiousStatuses)

            # The latest status is always current
            if i == 1
                infectiousStatus.isCurrent = true

            # The second latest infectious status can also be considered 'current' if the
            #    it was confirmed that the latest status is not confirmed
            elseif (
                i == 2
                && first(infectiousStatuses).isConfirmed !== true
                && infectiousStatus.isConfirmed === true
                )
                infectiousStatus.isCurrent = true

            # The rest of the statuses are considered not current
            else
                infectiousStatus.isCurrent = false
            end

            # Update the status
            @mock PostgresORM.update_entity!(infectiousStatus, dbconn)

        end

    end

    return statuses

end
