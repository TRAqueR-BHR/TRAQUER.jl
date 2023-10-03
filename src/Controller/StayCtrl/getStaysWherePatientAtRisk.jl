function StayCtrl.getStaysWherePatientAtRisk(
    atRiskStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)::Vector{Stay}


    # ################## #
    # Retrieve all stays #
    # ################## #
    queryString = "
       SELECT s.*
       FROM stay s
       WHERE s.patient_id = \$1
       ORDER BY s.in_time
    "
    queryArgs = [atRiskStatus.patient.id]
    atRiskStays = PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        queryArgs,
        false,
        dbconn
    )


    # ################################################################################## #
    # Look for an infectious status 'not_at_risk' after the 'carrier' ref. time for this #
    # same infectious agent. It will allow to exclude the stays that started after the   #
    # ref. time of this 'not_at_risk' status                                             #
    # ################################################################################## #
    notAtRiskStatus = "
        SELECT ist.*
        FROM infectious_status ist
        WHERE ist.patient_id = \$1
            AND ist.infectious_agent = \$2
            AND ist.infectious_status = 'not_at_risk'
            AND ist.ref_time > \$3
        ORDER BY ist.ref_time
        LIMIT 1
        " |>
        n -> PostgresORM.execute_query_and_handle_result(
                n,
                InfectiousStatus,
                [
                    atRiskStatus.patient.id,
                    atRiskStatus.infectiousAgent,
                    atRiskStatus.refTime
                ],
                false,
                dbconn
            ) |> n -> if isempty(n) missing else first(n) end


    # ############################################################################## #
    # Remove the stays 'in the past' (relatively to the infectious status ref. time) #
    # ############################################################################## #
    infectiousStatusStay = StayCtrl.retrieveOneStay(
        atRiskStatus,
        dbconn
    )

    # For 'contact' status, start at the stay during which the infectious status started
    if atRiskStatus.infectiousStatus == InfectiousStatusType.contact
        filter!(
            s -> s.inTime >= infectiousStatusStay.inTime,
            atRiskStays
        )
    # For 'carrier' status, all the stays of the hospitalization
    elseif atRiskStatus.infectiousStatus == InfectiousStatusType.carrier
        filter!(
            s -> s.hospitalizationInTime == infectiousStatusStay.hospitalizationInTime,
            atRiskStays
        )
    else
        error("Unsupported InfectiousStatusType[$atRiskStatus]")
    end

    # For carrier, check if the patient was isolated during one of the stays, in which case
    # we can remove all the stays that started after the isolationTime
    if atRiskStatus.infectiousStatus == InfectiousStatusType.carrier
        isolationTimeOverHospitalization = getproperty.(atRiskStays,:isolationTime) |>
            skipmissing |>
            collect |>
            n -> if isempty(n) missing else first(n) end
        if !ismissing(isolationTimeOverHospitalization)
            filter!(
                s -> begin
                    s.inTime <= isolationTimeOverHospitalization
                end,
                atRiskStays
            )
        end
    end

    # ################################################################################ #
    # Remove the stays 'in the future' (relatively to the infectious status ref. time) #
    # ################################################################################ #
    if !ismissing(notAtRiskStatus)
        filter!(
            s -> begin

                # This is debatable, but we chose to consider that a stay that ended after
                # the not_at_risk status time is not at risk
                if (!ismissing(s.outTime) && s.outTime > notAtRiskStatus.refTime)
                    return false
                end

                if s.inTime > notAtRiskStatus.refTime
                    return false
                end

                return true

            end,
            atRiskStays
        )
    end

    # filter!(
    #     stay -> StayCtrl.isStayAtRisk(
    #                 stay,
    #                 atRiskStatus,
    #                 notAtRiskStatus
    #             ),
    #     atRiskStays
    # )

    return atRiskStays

end
