function MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposuresAndReprocessPatientData(
    patient::Patient,
    ;forceProcessingTime::Union{Missing,ZonedDateTime} = missing,
)

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposuresAndReprocessPatientData(
            patient,
            dbconn
            ;forceProcessingTime = forceProcessingTime
        )
    end

end



function MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposuresAndReprocessPatientData(
    patient::Patient,
    dbconn::LibPQ.Connection
    ;forceProcessingTime::Union{Missing,ZonedDateTime} = missing,
)

    MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures(
        patient,
        dbconn
    )
    SchedulerCtrl.processNewlyIntegratedData(
        dbconn
        ;patient = patient,
        forceProcessingTime = forceProcessingTime
    )

end
