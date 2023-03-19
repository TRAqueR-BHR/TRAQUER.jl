"""

    createNewStayEventIfPatientAtRisk(
        stay::Stay,
        dbconn::LibPQ.Connection
    )::Union{EventRequiringAttention, Nothing}

Create an new_stay event if the patient is at risk when it starts the stay
"""
function EventRequiringAttentionCtrl.createNewStayEventIfPatientAtRisk(
    stay::Stay,
    dbconn::LibPQ.Connection
)::Union{EventRequiringAttention, Nothing}

    # We want to know the status a few seconds before the beginning of the stay to make sure
    #  we dont get a 'contact' status that coincide with the beginning of the stay and for
    #  which we dont want to create an event because there is already the event of the status
    timeOfInterest = stay.inTime - Second(2)

    # atRiskStatusAtTime::Union{Nothing, InfectiousStatus} =
    atRiskStatusAtTime::Union{Nothing, InfectiousStatus} =
        InfectiousStatusCtrl.getInfectiousStatusAtTime(
            stay.patient,
            timeOfInterest,
            false, # retrieveComplexProps,
            dbconn
            ;statusesOfInterest = [InfectiousStatusType.carrier, InfectiousStatusType.contact]
        )

    # If no 'at risk' infectious status was found, we dont create an event because this is
    # of no interest
    if isnothing(atRiskStatusAtTime)
        return
    else
        eventRequiringAttention = EventRequiringAttention(
            infectiousStatus = atRiskStatusAtTime,
            isPending = true,
            eventType = EventRequiringAttentionType.new_stay,
            refTime = stay.inTime
        )

        EventRequiringAttentionCtrl.upsert!(eventRequiringAttention, dbconn)

        return eventRequiringAttention

    end

end
