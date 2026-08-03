"""
    mergeStayMonitoringScopeDTOs(
        stayMonitoringScopeDTOs::Vector{Model.DTO.StayMonitoringScopeDTO},
    )::Vector{Model.DTO.StayMonitoringScopeDTO}

Merge stay monitoring scope DTOs that target the same unit/patient pair by
keeping the lowest start time and the highest end time.
"""
function ETLCtrl.ScopeCtrl.mergeStayMonitoringScopeDTOs(
    stayMonitoringScopeDTOs::Vector{Model.DTO.StayMonitoringScopeDTO},
)::Vector{Model.DTO.StayMonitoringScopeDTO}

    # Group DTOs by their monitoring target: unit and/or patient.
    mergedByTarget = Dict{
        Tuple{Union{Missing, String}, Union{Missing, String}},
        Model.DTO.StayMonitoringScopeDTO,
    }()

    for stayMonitoringScopeDTO in stayMonitoringScopeDTOs
        key = (
            stayMonitoringScopeDTO.monitoredUnitCodeName,
            stayMonitoringScopeDTO.monitoredPatientRef,
        )

        # First DTO for a target: keep it as the initial merged value.
        if !haskey(mergedByTarget, key)
            mergedByTarget[key] = stayMonitoringScopeDTO
            continue
        end

        existingStayMonitoringScopeDTO = mergedByTarget[key]

        # Expand the merged period to cover both DTOs.
        # If one side is missing, keep missing because it is less restrictive.
        periodOiStartTime = if (
            ismissing(existingStayMonitoringScopeDTO.periodOiStartTime)
            || ismissing(stayMonitoringScopeDTO.periodOiStartTime)
        )
            missing
        else
            min(
                existingStayMonitoringScopeDTO.periodOiStartTime,
                stayMonitoringScopeDTO.periodOiStartTime,
            )
        end

        periodOiEndTime = if (
            ismissing(existingStayMonitoringScopeDTO.periodOiEndTime)
            || ismissing(stayMonitoringScopeDTO.periodOiEndTime)
        )
            missing
        else
            max(
                existingStayMonitoringScopeDTO.periodOiEndTime,
                stayMonitoringScopeDTO.periodOiEndTime,
            )
        end

        # Keep the earliest request time so the merged DTO remains conservative.
        requestTime = if ismissing(existingStayMonitoringScopeDTO.requestTime)
            stayMonitoringScopeDTO.requestTime
        elseif ismissing(stayMonitoringScopeDTO.requestTime)
            existingStayMonitoringScopeDTO.requestTime
        else
            min(
                existingStayMonitoringScopeDTO.requestTime,
                stayMonitoringScopeDTO.requestTime,
            )
        end

        mergedByTarget[key] = Model.DTO.StayMonitoringScopeDTO(
            id = existingStayMonitoringScopeDTO.id,
            requestTime = requestTime,
            periodOiStartTime = periodOiStartTime,
            periodOiEndTime = periodOiEndTime,
            monitoredUnitCodeName = existingStayMonitoringScopeDTO.monitoredUnitCodeName,
            monitoredPatientRef = existingStayMonitoringScopeDTO.monitoredPatientRef,
        )
    end

    mergedStayMonitoringScopeDTOs = collect(values(mergedByTarget))

    # Sort the result to keep a deterministic output order.
    sort!(
        mergedStayMonitoringScopeDTOs,
        by = x -> (
            x.monitoredUnitCodeName,
            x.monitoredPatientRef,
            x.periodOiStartTime,
            x.periodOiEndTime,
        ),
    )

    return mergedStayMonitoringScopeDTOs
end
