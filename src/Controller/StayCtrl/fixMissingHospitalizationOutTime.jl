function StayCtrl.fixMissingHospitalizationOutTime(
    stays::Vector{Stay},
    dbconn::LibPQ.Connection
    ;simulate::Bool = false
)

    # Sort the stays by inTime
    stays = sort!(stays, by = x -> x.inTime)

    # Iterate from the one before last until the first
    staysThatNeedAFix = Stay[]
    for i in length(stays)-1:-1:1
        stay = stays[i]
        nextStay = stays[i+1]

        if !ismissing(stay.hospitalizationOutTime)
            continue
        end

        # If different hospitalization than the next stay, use the outTime as hospitalizationOutTime
        if stay.hospitalizationInTime != nextStay.hospitalizationInTime
            # There should at least be an outTime
            if ismissing(stay.outTime)
                error(
                    "Problem while trying to fix missing hospitalizationOutTime for "
                    * "Stay[$(stay.id)]. Stay has no outTime whereas next stay[$(nextStay.id)]"
                    *" is for a different hospitalization"
                )
            end
            stay.hospitalizationOutTime = stay.outTime
            push!(staysThatNeedAFix, stay)

        # If same hospitalization
        else

            # If the next stay has an hospitalizationOutTime use it
            if !ismissing(nextStay.hospitalizationOutTime)
                stay.hospitalizationOutTime = nextStay.hospitalizationOutTime
                push!(staysThatNeedAFix, stay)
            end

        end

    end

    if !simulate
        PostgresORM.update_entity!.(staysThatNeedAFix,dbconn)
    end

    return stays

end

function StayCtrl.fixMissingHospitalizationOutTime(
    patient::Patient,
    dbconn::LibPQ.Connection
    ;simulate::Bool = false
)

    # Retrieve all stays of patient
    queryString = "SELECT s.* FROM stay s WHERE s.patient_id = \$1 ORDER BY s.in_time"
    stays = @mock PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        [patient.id],
        false,
        dbconn
    )

    StayCtrl.fixMissingHospitalizationOutTime(
        stays,
        dbconn
        ;simulate = simulate
    )

end
