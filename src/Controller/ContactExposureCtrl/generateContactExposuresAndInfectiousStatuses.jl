function ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(
    asso::OutbreakConfigUnitAsso, dbconn::LibPQ.Connection)

    PostgresORM.update_entity!(asso, dbconn)

    exposures::Vector{ContactExposure} = ContactExposureCtrl.generateContactExposures(asso, dbconn)

    for exposure in exposures

        InfectiousStatusCtrl.generateContactStatusFromExposure(exposure,dbconn)

        # InfectiousStatusCtrl.generateContactStatusesFromContactExposures(
        #     exposure.contact,
        #     (asso.startTime |> Date, asso.endTime |> Date),
        #     dbconn)
    end

end
