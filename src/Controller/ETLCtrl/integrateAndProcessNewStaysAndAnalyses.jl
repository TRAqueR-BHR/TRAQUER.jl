function ETLCtrl.integrateAndProcessNewStaysAndAnalyses(cryptStr::String)

    @info "##### ETLCtrl.integrateAndProcessNewStaysAndAnalyses"
    # error("NASTY ERROR")
    ETLCtrl.importStays(cryptStr)
    ETLCtrl.importAnalyses(cryptStr)
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        ETLCtrl.processNewlyIntegratedData(dbconn)
    end
end
