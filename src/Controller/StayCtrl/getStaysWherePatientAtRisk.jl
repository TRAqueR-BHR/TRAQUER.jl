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

# Case where the infectious status is not in a stay

Hospitalization:             [========]  [=====================]   [======================]
outbreak.refTime:
Infectious status:      🍎                                           🍏
Isolation:                     📢                  📢
All stays:                   [===][===]  [====][=======][======]    [====][=======][======]
stays at risk:                 ✓           ✓       ✓                 ✓


"""
function StayCtrl.getStaysWherePatientAtRisk(
    atRiskStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)::Vector{Stay}

    # Get the current max processing time so that we dont generate contact statuses beyond
    # the date where we stopped (useful when simulating)
    maxProcessingTime = ETLCtrl.getMaxProcessingTime(dbconn)

    # Assume this function is used on at risk  statuses only
    if atRiskStatus.infectiousStatus ∉ [
        InfectiousStatusType.contact,
        InfectiousStatusType.carrier,
        InfectiousStatusType.suspicion
    ]
        error("Unsupported InfectiousStatusType[$atRiskStatus]")
    end


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


    # ################################## #
    # Filter out the stays 'in the past' #
    # ################################## #

    # 1. Fisrt filter based on the hospitalization date (for carrier/suspicion) or
    #    the stay in time (for contact)

    # Get the stay where the patient got the status
    infectiousStatusStay = StayCtrl.retrieveOneStay(
        atRiskStatus,
        dbconn
    )

    # There may be no stay for the infectious status, for example when a status is created
    # independly of any stay. In that case use the next stay in the history
    if !ismissing(infectiousStatusStay)

        # For 'contact' status, start at the stay during which the infectious status started
        if atRiskStatus.infectiousStatus == InfectiousStatusType.contact

            filter!(
                s -> s.inTime >= infectiousStatusStay.inTime,
                atRiskStays
            )

        # For 'carrier' and 'suspicion' status, take all the stays starting at the hospitalization
        # where the infectious status got created
        elseif atRiskStatus.infectiousStatus ∈ [
            InfectiousStatusType.carrier, InfectiousStatusType.suspicion
        ]
            filter!(
                s -> s.hospitalizationInTime >= infectiousStatusStay.hospitalizationInTime,
                atRiskStays
            )

        else
            error("Unsupported InfectiousStatusType[$atRiskStatus]")
        end

    # Drop all the stays that started before the status ref. time
    else
        filter!(
            s -> s.inTime >= atRiskStatus.refTime,
            atRiskStays
        )
    end

    # 2. If the patient was not at risk when entering the hospital (i.e. no status or
    # status 'not_at_risk'), only keep the stay where the patient became carrier/suspicion
    # and the ones after
    if (
        !ismissing(infectiousStatusStay)
        && atRiskStatus.infectiousStatus ∈ [
            InfectiousStatusType.carrier, InfectiousStatusType.suspicion
        ]
    )

        # Get the status of the patient at the beginning of the hospitalization
        infectiousStatusAtHospitalization = InfectiousStatusCtrl.getInfectiousStatusAtTime(
            atRiskStatus.patient,
            atRiskStatus.infectiousAgent,
            infectiousStatusStay.hospitalizationInTime,
            false, # retrieveComplexProps::Bool,
            dbconn
        )

        # If patient was not at risk or just contact, look for a negative analysis
        if (
            ismissing(infectiousStatusAtHospitalization)
            || infectiousStatusAtHospitalization.infectiousStatus ∈
                [InfectiousStatusType.not_at_risk, InfectiousStatusType.contact]
            )

            lastNegativeResult = AnalysisResultCtrl.getLastNegativeResultWithinPeriod(
                atRiskStatus.patient,
                atRiskStatus.infectiousAgent,
                infectiousStatusStay.hospitalizationInTime,
                atRiskStatus.refTime,
                dbconn
            )

            # Drop the stays that ended before the last negative result. The stay of the
            # negative result is considered at risk because the patient may have become
            # positive during that stay
            if !ismissing(lastNegativeResult)
                filter!(
                    s -> begin
                       #  Negative analysis result:            ⬇
                       #  Stays:                     [=====][=====][=====]   [========][===]
                       #  Keep:                         no    yes    yes         yes    yes
                       if !ismissing(s.outTime) && s.outTime < lastNegativeResult.requestTime
                            return false
                       else
                            return true
                       end
                    end,
                    atRiskStays
                )
            end

        end

    end

    # #################################################################################### #
    # For carrier and 'suspicion' for a given hospitalization, only keep the stays that    #
    # started before the isolation time (if any)                                           #
    # #################################################################################### #
    if atRiskStatus.infectiousStatus ∈ [InfectiousStatusType.carrier, InfectiousStatusType.suspicion]

        # Get all the stays during which the patient was isolated (accross all hospit.)
        staysWithIsolation = filter(s -> !ismissing(s.isolationTime),atRiskStays)

        # Filter the stays based on those stays with isolation
        filter!(
            s -> begin

                # Look for an isolation time for that hospitalization
                # NOTE: We assume that there is only one isolation time declared
                # per hospitalization, if there are several then we take the first
                # one that comes (TODO: Do better than this).
                # One could think "A new isolation should be declared for every stay", the
                # answer is no because knowing that we have 'new_stay' events, we can
                # consider that the subsequent stays are not at risk
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
    end

    # ###################################################### #
    # Remove the stays where patient was not at risk anymore #
    # ###################################################### #
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

    return atRiskStays

end
