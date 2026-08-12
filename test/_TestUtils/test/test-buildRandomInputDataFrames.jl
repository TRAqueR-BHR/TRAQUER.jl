include("__prerequisite.jl")

using DataFrames

@testset "Test _TestUtils.buildInputDataFrames" begin
    dfs = _TestUtils.buildInputDataFrames(nbPatients = 5)

    expectedStaysColumns = [
        :patient_ref,
        :firstname,
        :lastname,
        :birthdate,
        :hospitalization_in_time,
        :hospitalization_out_time,
        :unit_code_name,
        :unit_name,
        :sector,
        :room,
        :unit_in_time,
        :unit_out_time,
        :patient_died_during_stay,
    ]
    expectedAnalysesColumns = [
        :patient_ref,
        :firstname,
        :lastname,
        :birthdate,
        :analysis_ref,
        :status,
        :request_time,
        :result_time,
        :sample,
        :request_type,
        :result,
    ]

    @test dfs.stays isa DataFrame
    @test dfs.analyses isa DataFrame
    @test propertynames(dfs.stays) == expectedStaysColumns
    @test propertynames(dfs.analyses) == expectedAnalysesColumns
    @test length(unique(dfs.stays.patient_ref)) == 5
    @test length(unique(dfs.analyses.patient_ref)) == 5

    @test all(r -> r.birthdate isa Date, eachrow(dfs.stays))
    @test all(r -> r.unit_in_time >= r.hospitalization_in_time, eachrow(dfs.stays))
    @test all(
        r -> ismissing(r.unit_out_time) || r.unit_out_time >= r.unit_in_time,
        eachrow(dfs.stays),
    )
    @test all(
        r -> ismissing(r.hospitalization_out_time) ||
            r.hospitalization_out_time >= r.hospitalization_in_time,
        eachrow(dfs.stays),
    )
    @test all(
        r -> ismissing(r.result_time) || r.result_time >= r.request_time,
        eachrow(dfs.analyses),
    )

    emptyDfs = _TestUtils.buildInputDataFrames(nbPatients = 0)
    @test emptyDfs.stays isa DataFrame
    @test emptyDfs.analyses isa DataFrame
    @test nrow(emptyDfs.stays) == 0
    @test nrow(emptyDfs.analyses) == 0
    @test propertynames(emptyDfs.stays) == expectedStaysColumns
    @test propertynames(emptyDfs.analyses) == expectedAnalysesColumns

    @test_throws ArgumentError _TestUtils.buildInputDataFrames(nbPatients = -1)
end
