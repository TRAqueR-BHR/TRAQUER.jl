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


    # StayMonitoringScope is either : 
    # - Patient-oriented
    # - Unit-oriented
    # - Could be both for not now yet.
    patient::Union{Missing, Patient} = stayMonitoringScope.monitoredPatient
    unit::Union{Missing, Unit} = stayMonitoringScope.monitoredUnit
    if !ismissing(patient)
        # Go back to the period of the patient's last stay.
        queryString = "
        SELECT *
           FROM stay
        WHERE patient_id = \$1
        ORDER BY in_time DESC
        LIMIT 1
        "

        queryArgs = [patient.id]

        lastKnownStay = queryString |>
            n -> PostgresORM.execute_query_and_handle_result(
                n,
                Stay,
                queryArgs,
                false,
                dbconn
            ) |>
            n -> if isempty(n) missing else first(n) end
        
        periodOiStartTime = if !ismissing(lastKnownStay) 
            lastKnownStay.inTime + Second(1)
        else
            stayMonitoringScope.periodOiStartTime
        end

        periodOiEndTime = missing
        
    elseif !ismissing(unit)
        # TODO think about a smart way to handle this scenario
    end
    
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
