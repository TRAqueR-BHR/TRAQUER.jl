"""
    mergeStayExtractionScopeDTOs(
        stayExtractionScopeDTOs::Vector{Model.DTO.StayExtractionScopeDTO},
    )::Vector{Model.DTO.StayExtractionScopeDTO}

Merge stay extraction scope DTOs that target the same unit/patient pair by
keeping the lowest start time and the highest end time.
"""
function ETLCtrl.ScopeCtrl.mergeStayExtractionScopeDTOs(
    stayExtractionScopeDTOs::Vector{Model.DTO.StayExtractionScopeDTO},
)::Vector{Model.DTO.StayExtractionScopeDTO}

    # Group DTOs by their extraction target: unit and/or patient.
    mergedByTarget = Dict{
        Tuple{Union{Missing, String}, Union{Missing, String}},
        Model.DTO.StayExtractionScopeDTO,
    }()

    for stayExtractionScopeDTO in stayExtractionScopeDTOs
        key = (
            stayExtractionScopeDTO.monitoredUnitCodeName,
            stayExtractionScopeDTO.monitoredPatientRef,
        )

        # First DTO for a target: keep it as the initial merged value.
        if !haskey(mergedByTarget, key)
            mergedByTarget[key] = stayExtractionScopeDTO
            continue
        end

        existingStayExtractionScopeDTO = mergedByTarget[key]

        # Expand the merged period to cover both DTOs.
        # If one side is missing, keep missing because it is less restrictive.
        periodOiStartTime = if (
            ismissing(existingStayExtractionScopeDTO.periodOiStartTime)
            || ismissing(stayExtractionScopeDTO.periodOiStartTime)
        )
            missing
        else
            min(
                existingStayExtractionScopeDTO.periodOiStartTime,
                stayExtractionScopeDTO.periodOiStartTime,
            )
        end

        periodOiEndTime = if (
            ismissing(existingStayExtractionScopeDTO.periodOiEndTime)
            || ismissing(stayExtractionScopeDTO.periodOiEndTime)
        )
            missing
        else
            max(
                existingStayExtractionScopeDTO.periodOiEndTime,
                stayExtractionScopeDTO.periodOiEndTime,
            )
        end

        # Keep the earliest request time so the merged DTO remains conservative.
        requestTime = if ismissing(existingStayExtractionScopeDTO.requestTime)
            stayExtractionScopeDTO.requestTime
        elseif ismissing(stayExtractionScopeDTO.requestTime)
            existingStayExtractionScopeDTO.requestTime
        else
            min(
                existingStayExtractionScopeDTO.requestTime,
                stayExtractionScopeDTO.requestTime,
            )
        end

        # Concatenate the extraction scope IDs from both DTOs
        extractionScopesIds = vcat(
            existingStayExtractionScopeDTO.extractionScopesIds,
            stayExtractionScopeDTO.extractionScopesIds,
        )

        mergedByTarget[key] = Model.DTO.StayExtractionScopeDTO(
            id = existingStayExtractionScopeDTO.id,
            requestTime = requestTime,
            periodOiStartTime = periodOiStartTime,
            periodOiEndTime = periodOiEndTime,
            monitoredUnitCodeName = existingStayExtractionScopeDTO.monitoredUnitCodeName,
            monitoredPatientRef = existingStayExtractionScopeDTO.monitoredPatientRef,
            extractionScopesIds = extractionScopesIds,
        )
    end

    mergedStayExtractionScopeDTOs = collect(values(mergedByTarget))

    # Sort the result to keep a deterministic output order.
    sort!(
        mergedStayExtractionScopeDTOs,
        by = x -> (
            x.monitoredUnitCodeName,
            x.monitoredPatientRef,
            x.periodOiStartTime,
            x.periodOiEndTime,
        ),
    )

    return mergedStayExtractionScopeDTOs
end
