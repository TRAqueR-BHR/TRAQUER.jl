function OutbreakCtrl.getOutbreakFromEventRequiringAttention(
    eventRequiringAttention::EventRequiringAttention,
    retrieveComplexProperties::Bool,
    dbconn::LibPQ.Connection
)::Union{Missing, Outbreak}

    eventRefTime = eventRequiringAttention.refTime
    infectiousStatus = eventRequiringAttention.infectiousStatus

    if ismissing(eventRefTime)
        error("EventRequiringAttention[$(eventRequiringAttention.id)] has property refTime[missing]")
    end
    if ismissing(infectiousStatus)
        @info ("EventRequiringAttention[$(eventRequiringAttention.id)] has property "
        *"infectiousStatus[missing] => return missing")
        return missing
    end

    outbreak::Union{Missing, Outbreak} = "
        SELECT o.*
        FROM infectious_status _is
        JOIN outbreak_infectious_status_asso oisa
        ON _is.id = oisa.infectious_status_id
        JOIN outbreak o
        ON o.id = oisa.outbreak_id
        WHERE _is.id = \$1
    " |>
        n -> execute_query_and_handle_result(
                n, Outbreak, [infectiousStatus.id], retrieveComplexProperties, dbconn) |>
        n -> if isempty(n)
            missing
        else
            # Get the outbreak with the closest ref. time to the event ref. time
            sort!(
                n
                ;lt = (a, b) -> abs(a.refTime - eventRefTime) < abs(b.refTime - eventRefTime)
            )
            first(n)
        end

    return outbreak

end
