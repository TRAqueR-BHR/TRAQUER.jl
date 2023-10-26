"""
    EventRequiringAttentionCtrl.getNewImportantEvents(dbconn::LibPQ.Connection)

Get the Vector{EventRequiringAttentionCtrl} of important events that were created since last
time EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents was executed
"""
function EventRequiringAttentionCtrl.getNewImportantEvents(dbconn::LibPQ.Connection)::Vector{EventRequiringAttention}

    lastExecution = SchedulerCtrl.getLastExecution(
        TRAQUER.Controller.EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents,
        dbconn
    )

    lowerLimit = if ismissing(lastExecution)
            ZonedDateTime(
                DateTime("1970-01-01"),
                TRAQUERUtil.getTimeZone()
            )
        else
            lastExecution.startTime
        end

    lastEvents = "SELECT e.*
    FROM event_requiring_attention e
    WHERE e.is_pending = 't'
    --AND e.creation_time IS NOT NULL
    --AND e.creation_time >= \$1
    ORDER BY e.creation_time DESC
    " |>
    n -> PostgresORM.execute_query_and_handle_result(
            n,
            EventRequiringAttention,
            [
                # lowerLimit
            ],
            false,
            dbconn
        )

    # Exclude the events that dont ask for a notification
    filter!(
        x -> EventRequiringAttentionCtrl.requiresTeamNotification(x, dbconn),
        lastEvents
    )

    return lastEvents

end
