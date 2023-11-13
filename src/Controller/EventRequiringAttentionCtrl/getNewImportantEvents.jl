"""
    EventRequiringAttentionCtrl.getNewImportantEvents(dbconn::LibPQ.Connection)

Get the Vector{EventRequiringAttentionCtrl} of important events that were created since last
time EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents was executed
"""
function EventRequiringAttentionCtrl.getNewImportantEvents(dbconn::LibPQ.Connection)::Vector{EventRequiringAttention}


    lastEvents = "SELECT e.*
    FROM event_requiring_attention e
    WHERE e.is_pending = 't'
    AND e.is_notification_sent = 'f'
    AND e.creation_time IS NOT NULL
    AND e.creation_time > \$1 -- We dont want to go back too much in time because some events
                              -- do not generate a notification and therefore accumulate in
                              -- the stock of not notified events
    ORDER BY e.creation_time DESC
    " |>
    n -> PostgresORM.execute_query_and_handle_result(
            n,
            EventRequiringAttention,
            [now(getTimeZone()) - Week(2)],
            true, # we want details of the infectious status
            dbconn
        )

    # Exclude the events that dont ask for a notification
    filter!(
        x -> EventRequiringAttentionCtrl.requiresTeamNotification(x, dbconn),
        lastEvents
    )

    return lastEvents

end
