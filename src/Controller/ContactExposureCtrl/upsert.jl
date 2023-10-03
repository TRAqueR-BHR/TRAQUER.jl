function ContactExposureCtrl.upsert!(contactExposure::ContactExposure, dbconn::LibPQ.Connection)

    # Check whether an exposure already exists,
    # NOTE: When looking for an existing exposure, we dont use the outbreak in the filter
    #       so that we dont create a duplicate exposure (this can happen when an infectious
    #       status is associated to several outbreaks)
    filterObject = ContactExposure(
        contact = contactExposure.contact,
        carrier = contactExposure.carrier,
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
