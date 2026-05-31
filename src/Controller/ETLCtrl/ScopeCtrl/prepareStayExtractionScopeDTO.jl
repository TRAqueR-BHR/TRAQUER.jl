function ETLCtrl.ScopeCtrl.prepareStayExtractionScopeDTO(
    stayExtractionScope::StayExtractionScope,
    encryptionStr::String,
    dbconn::LibPQ.Connection,
)::Model.DTO.StayExtractionScopeDTO

    stayMonitoringScope = stayExtractionScope.stayMonitoringScope

    # Lazy load stay monitoring scope if not already loaded.
    if ismissing(stayMonitoringScope.activationTime)
        stayMonitoringScope = PostgresORM.retrieve_one_entity(
            StayMonitoringScope(id = stayMonitoringScope.id),
            false,
            dbconn
        )
    end

    monitoredUnit = stayMonitoringScope.monitoredUnit
    monitoredPatient = stayMonitoringScope.monitoredPatient

    monitoredUnitCodeName = if ismissing(monitoredUnit)
        missing
    else
        if ismissing(monitoredUnit.codeName)
            monitoredUnit = PostgresORM.retrieve_one_entity(Unit(id = monitoredUnit.id), false, dbconn)
        end
        monitoredUnit.codeName
    end

    monitoredPatientRef = if ismissing(monitoredPatient)
        missing
    else
        patientDecrypt = PatientCtrl.getPatientDecrypt(
            monitoredPatient,
            encryptionStr,
            dbconn;
            includePatientRef = true
        )

        ismissing(patientDecrypt) ? missing : patientDecrypt.patientRef
    end

    return Model.DTO.StayExtractionScopeDTO(
        id = stayExtractionScope.id,
        requestTime = stayExtractionScope.requestTime,
        periodOiStartTime = stayMonitoringScope.periodOiStartTime,
        periodOiEndTime = stayMonitoringScope.periodOiEndTime,
        monitoredUnitCodeName = monitoredUnitCodeName,
        monitoredPatientRef = monitoredPatientRef,
        justificationAdditionalInfo = stayMonitoringScope.justificationAdditionalInfo,
    )

end
