"""
    getStayExtractionScopeDTOsForExtraction(
        encryptionStr::String,
        dbconn::LibPQ.Connection,
    )::Vector{Model.DTO.StayExtractionScopeDTO}

Refresh stay monitoring scopes, create extraction scopes for the active ones,
convert them to DTOs, and merge overlapping DTOs that target the same
unit/patient pair.
"""
function ETLCtrl.ScopeCtrl.getStayExtractionScopeDTOsForExtraction(
    encryptionStr::String,
    dbconn::LibPQ.Connection,
)::Vector{Model.DTO.StayExtractionScopeDTO}
    # First refresh the monitoring scopes from the current infectious statuses at risk.
    ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes(dbconn)

    # Only active monitoring scopes should generate extraction requests.
    activeStayMonitoringScopes = ETLCtrl.ScopeCtrl.getActiveStayMonitoringScopes(dbconn)

    # Persist one extraction scope per active monitoring scope for this request.
    stayExtractionScopes = StayExtractionScope[]
    for stayMonitoringScope in activeStayMonitoringScopes
        stayExtractionScope = ETLCtrl.ScopeCtrl.createStayExtractionScope(
            stayMonitoringScope,
            dbconn,
        )
        push!(stayExtractionScopes, stayExtractionScope)
    end

    # Convert persisted extraction scopes to transport DTOs.
    stayExtractionScopeDTOs = Model.DTO.StayExtractionScopeDTO[]
    for stayExtractionScope in stayExtractionScopes
        stayExtractionScopeDTO = ETLCtrl.ScopeCtrl.prepareStayExtractionScopeDTO(
            stayExtractionScope,
            encryptionStr,
            dbconn,
        )
        push!(stayExtractionScopeDTOs, stayExtractionScopeDTO)
    end

    # Merge DTOs that target the same unit/patient pair.
    mergedStayExtractionScopeDTOs = ETLCtrl.ScopeCtrl.mergeStayExtractionScopeDTOs(
        stayExtractionScopeDTOs,
    )

    return mergedStayExtractionScopeDTOs
end
