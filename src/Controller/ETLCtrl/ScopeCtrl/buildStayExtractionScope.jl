"""
    buildStayExtractionScope(
        stayMonitoringScope::StayMonitoringScope,
        dbconn::LibPQ.Connection
    )::StayExtractionScope

Create a stay extraction scope based on a stay monitoring scope.

"""
function ETLCtrl.ScopeCtrl.buildStayExtractionScope(
    stayMonitoringScope::StayMonitoringScope,
    dbconn::LibPQ.Connection
)::StayExtractionScope

    requestTime = now(TRAQUERUtil.getTimeZone())

    # TODO: The period of interest start and end times are currently set to the same values
    #       as the stay monitoring scope, but they should be further restricted based on
    #       specific rules or criteria
    periodOiStartTime = stayMonitoringScope.periodOiStartTime
    periodOiEndTime = stayMonitoringScope.periodOiEndTime


    stayExtractionScope = StayExtractionScope(
        stayMonitoringScope = stayMonitoringScope,
        periodOiStartTime = periodOiStartTime,
        periodOiEndTime = periodOiEndTime,
        requestTime = requestTime,
        id = UUIDs.uuid4() |> string # Initialize the id here instead of letting the database
                                     # generate it, so that unit tests involving the creation
                                     # of StayExtractionScopeDTO dont fail when trying to
                                     # set extractionScopesIds::Vector{String}
    )

end
