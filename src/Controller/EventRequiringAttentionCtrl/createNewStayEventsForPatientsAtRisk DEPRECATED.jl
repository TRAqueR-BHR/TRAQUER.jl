"""
    EventRequiringAttentionCtrl.createNewStayEventsForPatientsAtRisk(
        stays::Vector{Stay},
        dbconn::LibPQ.Connection
    )

Create an new_stay event for contact and carrier patients, unless there is already a
'new_infectious' event for the same ref. time.

Indeed, when a patient enters a unit where a carrier is staying, that will generate a
contact infectious status and its associated event. That is enough.
"""
function EventRequiringAttentionCtrl.createNewStayEventsForPatientsAtRisk(
    stays::Vector{Stay},
    dbconn::LibPQ.Connection
)

    patients = getproperty.(stays, :patient)
    patientsIDs = getproperty.(patients, :id)

    # Get the current contact infectious status of the patients and their associated events
    queryString = "
        SELECT
            ist.id AS infectious_status_id,
            ist.ref_time AS infectious_status_ref_time,
            ist.patient_id,
            era.ref_time AS event_ref_time,
            era.event_type
        FROM infectious_status ist
        JOIN event_requiring_attention era
          ON era.infectious_status_id = ist.id
        WHERE ist.is_current = 't'
        AND era.event_type = 'new_status'
        AND ist.patient_id = ANY(\$1)
        AND ist.infectious_status = 'contact'"
    queryParams = [
        patientsIDs
    ]

    df = PostgresORM.execute_plain_query(
        queryString,
        queryParams,
        dbconn
    )

    for stay in stays
        existingRow = filter(
            x -> (
                x.patient_id === stay.patient.id &&
                x.infectious_status_ref_time === stay.inTime
            ),
            df
        ) |> !isempty

        # If there is not already an infectious status for that stay, create the event
        if !existingRow

            # Find the infectious status
            atRiskStatus = getInfectiousStatusAtTime(
                stay.patient,
                stay.inTime,
                false, # retrieveComplexProps::Bool,
                dbconn
                ;statusesOfInterest = [InfectiousStatusType.contact, InfectiousStatusType.carrier]
            )

            if !isnothing(atRiskStatus)
                eventRequiringAttention = EventRequiringAttention(
                    infectiousStatus = atRiskStatus,
                    isPending = true,
                    eventType = EventRequiringAttentionType.new_stay,
                    refTime = atRiskStatus.refTime
                )
                EventRequiringAttentionCtrl.upsert!(eventRequiringAttention, dbconn)
            end
        end

    end

end
