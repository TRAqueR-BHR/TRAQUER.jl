include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.mergeStayExtractionScopeDTOs" begin
    timeZone = TRAQUERUtil.getTimeZone()

    stayExtractionScopeDTOs = [
        Model.DTO.StayExtractionScopeDTO(
            id = "dto-1",
            requestTime = ZonedDateTime(DateTime("2024-01-03T10:00:00"), timeZone),
            periodOiStartTime = ZonedDateTime(DateTime("2024-01-02T08:00:00"), timeZone),
            periodOiEndTime = ZonedDateTime(DateTime("2024-01-02T12:00:00"), timeZone),
            monitoredUnitCodeName = "REA-A",
            monitoredPatientRef = missing,
            extractionScopesIds = ["dto-1"],
        ),
        Model.DTO.StayExtractionScopeDTO(
            id = "dto-2",
            requestTime = ZonedDateTime(DateTime("2024-01-03T09:00:00"), timeZone),
            periodOiStartTime = ZonedDateTime(DateTime("2024-01-02T07:00:00"), timeZone),
            periodOiEndTime = ZonedDateTime(DateTime("2024-01-02T13:00:00"), timeZone),
            monitoredUnitCodeName = "REA-A",
            monitoredPatientRef = missing,
            extractionScopesIds = ["dto-2"],
        ),
        Model.DTO.StayExtractionScopeDTO(
            id = "dto-3",
            requestTime = ZonedDateTime(DateTime("2024-01-04T09:00:00"), timeZone),
            periodOiStartTime = ZonedDateTime(DateTime("2024-01-04T07:00:00"), timeZone),
            periodOiEndTime = ZonedDateTime(DateTime("2024-01-04T08:00:00"), timeZone),
            monitoredUnitCodeName = missing,
            monitoredPatientRef = "PAT-001",
            extractionScopesIds = ["dto-3"],
        ),
        Model.DTO.StayExtractionScopeDTO(
            id = "dto-4",
            requestTime = ZonedDateTime(DateTime("2024-01-04T08:00:00"), timeZone),
            periodOiStartTime = ZonedDateTime(DateTime("2024-01-04T06:00:00"), timeZone),
            periodOiEndTime = ZonedDateTime(DateTime("2024-01-04T09:00:00"), timeZone),
            monitoredUnitCodeName = missing,
            monitoredPatientRef = "PAT-001",
            extractionScopesIds = ["dto-4"],
        ),
        Model.DTO.StayExtractionScopeDTO(
            id = "dto-5",
            requestTime = ZonedDateTime(DateTime("2024-01-05T08:00:00"), timeZone),
            periodOiStartTime = ZonedDateTime(DateTime("2024-01-05T06:00:00"), timeZone),
            periodOiEndTime = ZonedDateTime(DateTime("2024-01-05T09:00:00"), timeZone),
            monitoredUnitCodeName = "REA-B",
            monitoredPatientRef = missing,
            extractionScopesIds = ["dto-5"],
        ),
        Model.DTO.StayExtractionScopeDTO(
            id = "dto-6",
            requestTime = ZonedDateTime(DateTime("2024-01-05T07:00:00"), timeZone),
            periodOiStartTime = missing,
            periodOiEndTime = missing,
            monitoredUnitCodeName = "REA-B",
            monitoredPatientRef = missing,
            extractionScopesIds = ["dto-6"],
        ),
    ]

    mergedStayExtractionScopeDTOs = ETLCtrl.ScopeCtrl.mergeStayExtractionScopeDTOs(
        stayExtractionScopeDTOs,
    )

    # Serialize to a json file for easier inspection of the test output.
    mergedStayExtractionScopeDTOs |> JSON.json |>
        n -> open(joinpath("tmp","json", "merge_stay_extraction_scope_dtos.json"), "w") do f
            write(f, n)
        end

    @test length(mergedStayExtractionScopeDTOs) == 3

    unitScope = only(filter(
        x -> !ismissing(x.monitoredUnitCodeName) && x.monitoredUnitCodeName == "REA-A",
        mergedStayExtractionScopeDTOs,
    ))
    @test unitScope.periodOiStartTime ==
          ZonedDateTime(DateTime("2024-01-02T07:00:00"), timeZone)
    @test unitScope.periodOiEndTime ==
          ZonedDateTime(DateTime("2024-01-02T13:00:00"), timeZone)
    @test unitScope.requestTime ==
          ZonedDateTime(DateTime("2024-01-03T09:00:00"), timeZone)
    @test unitScope.extractionScopesIds == ["dto-1", "dto-2"]

    patientScope = only(filter(
        x -> !ismissing(x.monitoredPatientRef) && x.monitoredPatientRef == "PAT-001",
        mergedStayExtractionScopeDTOs,
    ))
    @test patientScope.periodOiStartTime ==
          ZonedDateTime(DateTime("2024-01-04T06:00:00"), timeZone)
    @test patientScope.periodOiEndTime ==
          ZonedDateTime(DateTime("2024-01-04T09:00:00"), timeZone)
    @test patientScope.requestTime ==
          ZonedDateTime(DateTime("2024-01-04T08:00:00"), timeZone)
    @test patientScope.extractionScopesIds == ["dto-3", "dto-4"]

    untouchedScope = only(filter(
        x -> !ismissing(x.monitoredUnitCodeName) && x.monitoredUnitCodeName == "REA-B",
        mergedStayExtractionScopeDTOs,
    ))
    @test untouchedScope.id == "dto-5"
    @test ismissing(untouchedScope.periodOiStartTime)
    @test ismissing(untouchedScope.periodOiEndTime)
    @test untouchedScope.requestTime ==
          ZonedDateTime(DateTime("2024-01-05T07:00:00"), timeZone)
    @test untouchedScope.extractionScopesIds == ["dto-5", "dto-6"]
end
