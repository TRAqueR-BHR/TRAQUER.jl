include("../../../test/runtests-prerequisite.jl")

@testset "Test Custom.convertETLInputDataToRequestAndResultType" begin

    # Ignore ATB2 lines that are something else than EPC or VRE
    @test Custom.convertETLInputDataToRequestAndResultType(
        "ATB2", # ANA_CODE
        missing, # "BMR"
        "1 ligne" # VALEUR_RESULTAT
    ) === nothing

    # Ignore ATB2 lines that are something else than EPC or VRE
    @test Custom.convertETLInputDataToRequestAndResultType(
        "ATB2", # ANA_CODE
        "BLSE+", # "BMR"
        "1 ligne" # VALEUR_RESULTAT
    ) === nothing

    # ANA_CODE == ATB2 && BMR == EPC
    @test Custom.convertETLInputDataToRequestAndResultType(
        "ATB2", # ANA_CODE
        "EPC", # "BMR"
        "1 ligne" # VALEUR_RESULTAT
    ) == (
        request = AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae,
        result = AnalysisResultValueType.positive
    )

    # ANA_CODE == ATB2 && BMR == VRE
    @test Custom.convertETLInputDataToRequestAndResultType(
        "ATB2", # ANA_CODE
        "VRE", # "BMR"
        "1 ligne" # VALEUR_RESULTAT
    ) == (
        request = AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus,
        result = AnalysisResultValueType.positive
    )

    # ANA_CODE == PREPC && VALEUR_RESULTAT == P
    # => Nothing, because we are only interested in ATB2 line in the positive case
    @test Custom.convertETLInputDataToRequestAndResultType(
        "PREPC", # ANA_CODE
        "something", # "BMR"
        "P" # VALEUR_RESULTAT
    ) === nothing

    # ANA_CODE == PREPC && VALEUR_RESULTAT == anything else than P
    # => bacterial culture for 'carba' bacteria is negative
    @test Custom.convertETLInputDataToRequestAndResultType(
        "PREPC", # ANA_CODE
        "something", # "BMR"
        "anything else than P" # VALEUR_RESULTAT
    ) == (
        request = AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae,
        result = AnalysisResultValueType.negative
    )

    # ANA_CODE == PRVRE && VALEUR_RESULTAT == anything else than P
    # => bacterial culture for 'vanco' bacteria is negative
    @test Custom.convertETLInputDataToRequestAndResultType(
        "PRVRE", # ANA_CODE
        "something", # "BMR"
        "anything else than P" # VALEUR_RESULTAT
    ) == (
        request = AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus,
        result = AnalysisResultValueType.negative
    )

    # ANA_CODE == PREPC && VALEUR_RESULTAT == missing
    # => result of bacterial culture for 'carba' is missing
    res = Custom.convertETLInputDataToRequestAndResultType(
        "PREPC", # ANA_CODE
        "something", # "BMR"
        missing # VALEUR_RESULTAT
    )
    @test res.request == AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae
    @test res.result === missing

    # ANA_CODE == PRVRE && VALEUR_RESULTAT == missing
    # => result of bacterial culture for 'vanco' is missing
    res = Custom.convertETLInputDataToRequestAndResultType(
        "PRVRE", # ANA_CODE
        "something", # "BMR"
        missing # VALEUR_RESULTAT
    )
    @test res.request == AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus
    @test res.result === missing

    # ANA_CODE == GXEPC && VALEUR_RESULTAT == missing
    # => result of molecular analysis for 'carba' is missing
    res = Custom.convertETLInputDataToRequestAndResultType(
        "GXEPC", # ANA_CODE
        "anything", # "BMR"
        missing # VALEUR_RESULTAT
    )
    @test res.request == AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae
    @test res.result === missing

    # ANA_CODE == GXERV && VALEUR_RESULTAT == missing
    # => result of molecular analysis for 'vanco' is missing
    res = Custom.convertETLInputDataToRequestAndResultType(
        "GXERV", # ANA_CODE
        "anything", # "BMR"
        missing # VALEUR_RESULTAT
    )
    @test res.request == AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus
    @test res.result === missing

    # ANA_CODE == GXERV && VALEUR_RESULTAT == P
    # => result of molecular analysis for 'vanco' is positive
    res = Custom.convertETLInputDataToRequestAndResultType(
        "GXERV", # ANA_CODE
        "anything", # "BMR"
        "P" # VALEUR_RESULTAT
    )
    @test res.request == AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus
    @test res.result === AnalysisResultValueType.positive

    # ANA_CODE == GXERV && VALEUR_RESULTAT == anything else than P
    # => result of molecular analysis for 'vanco' is positive
    res = Custom.convertETLInputDataToRequestAndResultType(
        "GXERV", # ANA_CODE
        "anything", # "BMR"
        "anything else than P" # VALEUR_RESULTAT
    )
    @test res.request == AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus
    @test res.result === AnalysisResultValueType.positive

end


Custom.convertETLInputDataToRequestAndResultType(
    "ATB2", # ANA_CODE
    "EPC", # "BMR"
    "1 ligne" # VALEUR_RESULTAT
)

(
    request = AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae,
    result = AnalysisResultValueType.positive
)
