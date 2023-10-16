function DeletedInfectiousStatusCtrl.create(
    infectiousStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)::DeletedInfectiousStatus

    if ismissing(infectiousStatus.patient)
        error("Cannot delete infectiousStatus because property 'patient' is missing")
    end
    if ismissing(infectiousStatus.infectiousAgent)
        error("Cannot delete infectiousStatus because property 'infectiousAgent' is missing")
    end
    if ismissing(infectiousStatus.refTime)
        error("Cannot delete infectiousStatus because property 'refTime' is missing")
    end
    if ismissing(infectiousStatus.infectiousStatus)
        error("Cannot delete infectiousStatus because property 'infectiousStatus' is missing")
    end

    obj = DeletedInfectiousStatus(
        patient = infectiousStatus.patient,
        infectiousAgent = infectiousStatus.infectiousAgent,
        refTime = infectiousStatus.refTime,
        infectiousStatus = infectiousStatus.infectiousStatus,
    )

    # We dont want to create duplicates
    existing = PostgresORM.retrieve_one_entity(obj,false,dbconn)
    if !ismissing(existing)
        return existing
    end

    PostgresORM.create_entity!(obj, dbconn)

    return obj

end
