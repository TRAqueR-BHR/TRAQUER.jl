function EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents(dbconn::LibPQ.Connection)
    # TODO
end

function EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents()

    createDBConnAndExecute() do dbconn
        EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents(dbconn)
    end

end
