function ETLCtrl.createPendingTask()

    createDBConnAndExecute() do dbconn
        ETLCtrl.createPendingTask(dbconn)
    end

end

function ETLCtrl.createPendingTask(dbconn::LibPQ.Connection)
    functionFullname = string(TRAQUER.ETLCtrl,".","integrateAndProcessNewStaysAndAnalyses")
    TaskWaitingForUserExecutionCtrl.createPendingTask(functionFullname, dbconn)
end
