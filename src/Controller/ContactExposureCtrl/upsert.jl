function ContactExposureCtrl.upsert!(contactExposure::ContactExposure, dbconn::LibPQ.Connection)

    # Check whether an exposure already exists
    filterObject = ContactExposure(
        contact = contactExposure.contact,
        outbreak = contactExposure.outbreak,
        unit = contactExposure.unit,
        startTime = contactExposure.startTime,
        endTime = contactExposure.endTime,
    )
    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)
    if ismissing(existing)
        PostgresORM.create_entity!(contactExposure,dbconn)
    else
        contactExposure.id =  existing.id
        PostgresORM.update_entity!(contactExposure,dbconn)
    end

end
