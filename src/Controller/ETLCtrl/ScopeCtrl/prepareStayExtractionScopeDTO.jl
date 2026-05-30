function ETLCtrl.ScopeCtrl.prepareStayExtractionScopeDTO(
    stayExtractionScope::StayExtractionScope,
    encryptionStr::String,
    dbconn::LibPQ.Connection,
)::StayExtractionScopeDTO

    stayMonitoringScope = stayExtractionScope.stayMonitoringScope

    # Lazy load stay monitoring scope if not already loaded.
    if ismissing(stayMonitoringScope.activationTime)
        stayMonitoringScope = PostgresORM.retrieve_one_entity(
            StayMonitoringScope(id = stayMonitoringScope.id),
            false,
            dbconn
        )
    end

    # Get the code names of the units in the scope, if any.
    unitCodeNames = if ismissing(stayMonitoringScope) || ismissing(stayMonitoringScope.unitIds)
        missing
    else
        map(
            strip,
            split(stayMonitoringScope.unitIds, ",")
        ) |>
        n -> filter(!isempty, n) |>
        n -> map(n) do unitId
            unit = PostgresORM.retrieve_one_entity(Unit(id = unitId), false, dbconn)
            unit.codeName
        end
    end

    # Get the patient hospital references in the scope, if any
    patientRefs = if ismissing(stayMonitoringScope) || ismissing(stayMonitoringScope.patientIds)
        missing
    else
        map(
            strip,
            split(stayMonitoringScope.patientIds, ",")
        ) |>
        n -> filter(!isempty, n) |>
        n -> map(n) do patientId
            patient = PostgresORM.retrieve_one_entity(Patient(id = patientId), false, dbconn)
            patientDecrypt = PatientCtrl.getPatientDecrypt(patient, encryptionStr, dbconn)

            if ismissing(patientDecrypt)
                missing
            else
                patientDecrypt.patientRef
            end
        end |>
        n -> filter(!ismissing, n)
    end

    return StayExtractionScopeDTO(
        id = stayExtractionScope.id,
        requestTime = stayExtractionScope.requestTime,
        periodOiStartTime = stayMonitoringScope.periodOiStartTime,
        periodOiEndTime = stayMonitoringScope.periodOiEndTime,
        unitCodeNames = unitCodeNames,
        patientRefs = patientRefs,
        justification = stayMonitoringScope.justification,
    )

end
