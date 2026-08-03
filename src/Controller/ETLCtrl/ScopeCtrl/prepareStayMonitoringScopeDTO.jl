function ETLCtrl.ScopeCtrl.prepareStayMonitoringScopeDTO(
    stayMonitoringScope::StayMonitoringScope,
    encryptionStr::String,
    dbconn::LibPQ.Connection,
)::Model.DTO.StayMonitoringScopeDTO

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

    return Model.DTO.StayMonitoringScopeDTO(
        id = UUIDs.uuid4() |> string, # Create a new random UUID for the DTO
        periodOiStartTime = stayMonitoringScope.periodOiStartTime,
        periodOiEndTime = stayMonitoringScope.periodOiEndTime,
        monitoredUnitCodeName = monitoredUnitCodeName,
        monitoredPatientRef = monitoredPatientRef,
    )

end
