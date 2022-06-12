function ContactExposureCtrl.upsert!(contactExposure::ContactExposure, dbconn::LibPQ.Connection)

    # Check whether an exposure already exists
    filterObject = ContactExposure(
        contact = contactExposure.contact,
        carrier = contactExposure.carrier,
        outbreak = contactExposure.outbreak,
        unit = contactExposure.unit,
        startTime = contactExposure.startTime,
    )
    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)
    if ismissing(existing)
        PostgresORM.create_entity!(contactExposure,dbconn)
    else
        contactExposure.id =  existing.id
        PostgresORM.update_entity!(contactExposure,dbconn)
    end

end
