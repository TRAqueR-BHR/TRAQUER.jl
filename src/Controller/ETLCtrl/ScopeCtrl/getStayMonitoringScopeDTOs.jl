"""
    getStayMonitoringScopeDTOs(
        encryptionStr::String,
        dbconn::LibPQ.Connection,
    )::Vector{Model.DTO.StayMonitoringScopeDTO}

Refresh stay monitoring scopes, convert them to DTOs, 
and merge overlapping DTOs that target the same unit/patient pair.
"""
function ETLCtrl.ScopeCtrl.getStayMonitoringScopeDTOs(
    encryptionStr::String,
    dbconn::LibPQ.Connection,
)::Vector{Model.DTO.StayMonitoringScopeDTO}
    # First refresh the monitoring scopes from the current infectious statuses at risk.
    ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes(dbconn)

    # Only active monitoring scopes should generate extraction requests.
    activeStayMonitoringScopes = ETLCtrl.ScopeCtrl.getActiveStayMonitoringScopes(dbconn)

    # Convert persisted extraction scopes to transport DTOs.
    stayMonitoringScopeDTOs = Model.DTO.StayMonitoringScopeDTO[]
    for stayMonitoringScope in activeStayMonitoringScopes
        stayMonitoringScopeDTO = ETLCtrl.ScopeCtrl.prepareStayMonitoringScopeDTO(
            stayMonitoringScope,
            encryptionStr,
            dbconn,
        )
        push!(stayMonitoringScopeDTOs, stayMonitoringScopeDTO)
    end

    # Merge DTOs that target the same unit/patient pair.
    mergedStayMonitoringScopeDTOs = ETLCtrl.ScopeCtrl.mergeStayMonitoringScopeDTOs(
        stayMonitoringScopeDTOs,
    )

    return mergedStayMonitoringScopeDTOs
end
