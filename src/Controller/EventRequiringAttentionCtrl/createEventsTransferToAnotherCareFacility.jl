"""
    EventRequiringAttentionCtrl.createEventsTransferToAnotherCareFacility(dbconn::LibPQ.Connection)

Create EventRequiringAttention instances for patients of interest that recently got out.

NOTE: We are relying on the upsert! function to not create duplicates

"""
function EventRequiringAttentionCtrl.createEventsTransferToAnotherCareFacility(dbconn::LibPQ.Connection)

    df = "
        SELECT ist.id AS infectious_status_id,
               s.hospitalization_out_time,
               s.hospitalization_out_comment
        FROM infectious_status ist
        JOIN patient p
        ON p.id = ist.patient_id
        JOIN stay s
        ON s.patient_id = p.id
        WHERE ist.is_confirmed = 't'
          AND ist.infectious_status = ANY(\$1)
          AND s.in_date > \$2 -- for performance
          AND s.hospitalization_out_time IS NOT NULL
          AND s.hospitalization_out_time > \$3
        " |>
        n -> PostgresORM.execute_plain_query(
            n,
            Any[
                [
                    InfectiousStatusType.carrier,
                    InfectiousStatusType.suspicion,
                    InfectiousStatusType.contact
                ],
                today() - Month(3), # A patient stays a maximum of 3 months
                now(getTimeZone()) - Hour(24)
            ],
            dbconn
        )

    events = EventRequiringAttention[]
    for r in eachrow(df)

        if !Custom.isTransferToAnotherCareFacility(r.hospitalization_out_comment)
            continue
        end

        eventRequiringAttention = EventRequiringAttention(
            infectiousStatus = InfectiousStatus(id = r.infectious_status_id),
            isPending = true,
            eventType = EventRequiringAttentionType.transfer_to_another_care_facility,
            refTime = r.hospitalization_out_time
        )
        EventRequiringAttentionCtrl.upsert!(eventRequiringAttention, dbconn)
        push!(events, eventRequiringAttention)
    end

    return events

end
