"""
    StayCtrl.getStaysWherePatientAtRisk(
        atRiskStatus::InfectiousStatus,
        dbconn::LibPQ.Connection
    )::Vector{Stay}

NOTE: In the following timelines, the infectious status, isolation, and stays are the ones
      of only one patient

# Case where a carrier is detected during hospitalization:

Hospitalization:     [======]  [=============================]   [========]
outbreak.refTime:                            ⬇(= infectiousStatus.startTime = analysis.requestTime)
Infectious status:                           🍎
Isolation:                                      📢
All stays:           [======]  [========][=========][========]   [========]
stays at risk:                      ✓         ✓


# Case where a carrier comes back for a new hospitalization:

Hospitalization:     [===]  [================]    [========]
outbreak.refTime:           ⬇(= hospitalizationInTime)
Infectious status:     🍎
Isolation:                            📢
All stays:           [===]  [=====][====][===]    [========]
stays at risk:         ✓       ✓     ✓


# Case where we have several carriers. In that case the outbreak ref time is the lowest time
# of the carriers (it doesnt matter, but note that it can be either an infectious.refTime or
# an hospitalization start time of another carrier):

Hospitalization:      [===]         [================]    [========]
outbreak.refTime:              ⬇(= a time from another carrier of the outbreak, either a
                                 hospitalizationInTime or a analysis.requestTime)
Infectious status:                            🍎
Isolation:                                    📢              📢
All stays:            [===]          [=====][====][===]   [========]
stays at risk:                                ✓               ✓



# TODO

Hospitalization:      [========]  [=====================]   [======================]
outbreak.refTime:
Infectious status:      🍎
Isolation:              📢                  📢                 📢
All stays:            [===][===]  [====][=======][======]    [====][=======][======]
stays at risk:          ✓           ✓       ✓                 ✓


# TODO

Hospitalization:      [========]  [=====================]   [======================]
outbreak.refTime:
Infectious status:      🍎                                     🍏
Isolation:              📢                  📢
All stays:            [===][===]  [====][=======][======]    [====][=======][======]
stays at risk:          ✓           ✓       ✓                 ✓



"""
function StayCtrl.getStaysWherePatientAtRisk(
    atRiskStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)::Vector{Stay}

    # Get the current max processing time so that we dont generate contact statuses beyond
    # the date where we stopped (useful when simulating)
    maxProcessingTime = ETLCtrl.getMaxProcessingTime(dbconn)


    # ############################################################## #
    # Retrieve all stays that started before the max processing time #
    # ############################################################## #
    queryString = "
       SELECT s.*
       FROM stay s
       WHERE s.patient_id = \$1
         AND s.in_time <= \$2
       ORDER BY s.in_time
    "
    queryArgs = [atRiskStatus.patient.id, maxProcessingTime]
    atRiskStays = PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        queryArgs,
        false,
        dbconn
    )


    # ##################################################################################### #
    # Look for an infectious status 'not_at_risk' after the 'carrier' ref. time for this    #
    # same infectious agent. It will allow to exclude the stays that started after the      #
    # ref. time of this 'not_at_risk' status.                                               #
    # In practice, because of the infectious status creation rules, the stay that will make #
    # the upper bound should be a 'not_at_risk' status                                      #
    # ##################################################################################### #
    notAtRiskStatus = "
        SELECT ist.*
        FROM infectious_status ist
        WHERE ist.patient_id = \$1
            AND ist.infectious_agent = \$2
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
    # For 'carrier' status, all the stays starting at the hospitalization where the
    # infectious status got created
    elseif atRiskStatus.infectiousStatus == InfectiousStatusType.carrier
        filter!(
            s -> s.hospitalizationInTime >= infectiousStatusStay.hospitalizationInTime,
            atRiskStays
        )
    else
        error("Unsupported InfectiousStatusType[$atRiskStatus]")
    end

    # For carrier, for a given hospitalization, only keep the stays that started before the
    # isolation time (if any)
    if atRiskStatus.infectiousStatus == InfectiousStatusType.carrier

        # Get all the stays during which the patient was isolated (accross all hospit.)
        staysWithIsolation = filter(s -> !ismissing(s.isolationTime),atRiskStays)

        # Filter the stays based on those stays with isolation
        filter!(
            s -> begin

                # Look for an isolation time for that hospitalization
                # NOTE: We assume that there is only one isolation time declared
                stayWithIsolationForSameHospitalization = filter(
                    st -> st.hospitalizationInTime == s.hospitalizationInTime,
                    staysWithIsolation
                ) |> n -> if isempty(n) missing else first(n) end
                if !ismissing(stayWithIsolationForSameHospitalization)
                    # If stay started before the isolationTime keep it
                    if s.inTime <= stayWithIsolationForSameHospitalization.isolationTime
                        return true
                    else
                        return false
                    end
                end
                return true
            end,
            atRiskStays
        )
        # isolationTimeOverHospitalization = getproperty.(atRiskStays,:isolationTime) |>
        #     skipmissing |>
        #     collect |>
        #     n -> if isempty(n) missing else first(n) end
        # if !ismissing(isolationTimeOverHospitalization)
        #     filter!(
        #         s -> begin
        #             s.inTime <= isolationTimeOverHospitalization
        #         end,
        #         atRiskStays
        #     )
        # end
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
