"""

Define the scope of the stay data needed for subsequent workflows (detection of contact,
creation of oubreak, etc...).

For a carrier and suspiscion we want to get all his stays regarless of time, unit, etc., we
also want to get all the stays of the units where the patient has been since he became a
carrier.
For contact we want to get only the stays of the patient the hospitalization where the
contact status has been identified.
"""
function ETLCtrl.ScopeCtrl.initializeStayMonitoringScope(
    infectiousStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)::Union{Nothing,Vector{StayMonitoringScope}}

    # Lazy load
    if ismissing(infectiousStatus.infectiousStatus) || ismissing(infectiousStatus.patient)
        infectiousStatus = PostgresORM.retrieve_one_entity(
            InfectiousStatus(id = infectiousStatus.id),
            false, # complex props
            dbconn
        )
    end

    patient::Patient = infectiousStatus.patient
    infectiouStatusStay::Union{Missing,Stay} = StayCtrl.retrieveOneStay(infectiousStatus,dbconn)

    # Check that the patient is actually at risk.
    if infectiousStatus.infectiousStatus ∉ INFECTIOUS_STATUS_TYPES_AT_RISK
        return nothing
    end

    scopes = Vector{StayMonitoringScope}()

    # ###################################### #
    # 1. Add a scope for the patient himself #
    # ###################################### #

    # For contact we want to get only the stays of this hospitalization
    if infectiousStatus.infectiousStatus ∈ [InfectiousStatusType.contact]

        if !ismissing(infectiouStatusStay)
            periodOiStartTime = infectiouStatusStay.hospitalizationInTime
            periodOiEndTime = infectiouStatusStay.hospitalizationOutTime
        else
            # Leave if blank => retrieve all stays of the patient, but this is not ideal
        end

    end

    # If patient is carrier we want to get all  his stays regarless of time, unit, etc.
    # Dont set anything


    stayMonitoringScope = StayMonitoringScope(;
        monitoredUnit = missing,
        monitoredPatient = monitoredPatient,
        justifyingInfectiousStatus = infectiousStatus,
        periodOiStartTime = missing,
        periodOiEndTime = missing,
        activationTime = now(TRAQUERUtil.getTimeZone())
    )

    push!(scopes, stayMonitoringScope)

    # #################################################################################### #
    # 2. If carrier/suspiscion, add a scope for the units where the patient has been since #
    #    he became a carrier/suspiscion                                                    #
    # #################################################################################### #
    if infectiousStatus.infectiousStatus ∈ [InfectiousStatusType.carrier, InfectiousStatusType.suspicion]

        stays::Vector{Stay} = StayCtrl.getSortedPatientStays(patient, dbconn)

        # Only keep the stays starting at the infectious status' stay
        if !ismissing(infectiouStatusStay)
            filter!(
                s -> s.inTime >= infectiouStatusStay.inTime,
                stays
            )
        end

        firstStayInScope = first(stays)
        lastStayInScope = last(stays)

        # Get the units of those stays
        units::Vector{Unit} = map(s -> s.unit, stays)

        for _unit in units

            monitoredUnit = _unit
            periodOiStartTime = firstStayInScope.inTime
            periodOiEndTime = lastStayInScope.outTime

            stayMonitoringScope = StayMonitoringScope(;
                monitoredUnit = monitoredUnit,
                monitoredPatient = missing,
                justifyingInfectiousStatus = infectiousStatus,
                periodOiStartTime = periodOiStartTime,
                periodOiEndTime = periodOiEndTime,
                activationTime = now(getTimeZone())
            )

            push!(scopes, stayMonitoringScope)

        end
    end

    return scopes

end
