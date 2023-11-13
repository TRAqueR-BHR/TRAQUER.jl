function EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents(dbconn::LibPQ.Connection)

    events = TRAQUERUtil.createDBConnAndExecute() do dbconn
        EventRequiringAttentionCtrl.getNewImportantEvents(dbconn)
    end

    if isempty(events)
        return
    end

    summary = EventRequiringAttentionCtrl.createSummaryOfEvents(events)

    subject = getTranslation("new_events_require_your_attention")
    message = summary

    TRAQUERUtil.notifyTeam(subject, message)

    # Update the database
    "UPDATE event_requiring_attention
    SET is_notification_sent = 't'
    WHERE id = ANY(\$1)" |>
    n -> PostgresORM.execute_plain_query(n, [getproperty.(events, :id)], dbconn)

end

function EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents()

    createDBConnAndExecute() do dbconn
        EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents(dbconn)
    end

end
