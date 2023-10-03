function Custom.convertETLInputDataToRequestAndResultType(
    ana_code::String,
    bmr::Union{Missing,String},
    valeur_resultat::Union{Missing,String}
)::Union{
    Nothing, # for when we ignore the line
    NamedTuple{
        (:request, :result),
        Tuple{ANALYSIS_REQUEST_TYPE, Union{Missing, ANALYSIS_RESULT_VALUE_TYPE}}
    }
}

    # ###################### #
    # For molecular analysis #
    # ###################### #
    if ana_code ∈ ["GXEPC", "GXERV"]

        # Convert to request type
        if ana_code == "GXEPC"
            request = AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae
        elseif ana_code == "GXERV"
            request = AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus
        end

        # Convert to result type
        if ismissing(valeur_resultat)
            result = missing
        elseif valeur_resultat == "P"
            result = AnalysisResultValueType.positive
        else
            result = AnalysisResultValueType.negative
        end

    # #################### #
    # For culture analysis #
    # #################### #
    elseif ana_code ∈ ["PREPC", "PRVRE", "ATB2"]

        # Reminder: Positive cultures are given by ATB2 lines
        if ana_code ∈ ["PREPC", "PRVRE"]

            # Ignore line, when PREPC and PRVRE are positive ('P') we look at the ATB2 line
            if valeur_resultat === "P"
                return nothing
            else
                if ana_code == "PREPC"
                    request = AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae
                elseif ana_code == "PRVRE"
                    request = AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus
                end

                # We may not have the result yet
                if ismissing(valeur_resultat)
                    result = missing
                else
                    result = AnalysisResultValueType.negative
                end
            end

        # Reminder: Negative cultures are given by PREPC and PRVRE lines
        elseif ana_code == "ATB2"
            if bmr === "EPC"
                request = AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae
                result = AnalysisResultValueType.positive
            elseif bmr === "VRE"
                request = AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus
                result = AnalysisResultValueType.positive
            else
                # Some ATB2 lines are not interesting. Even when BMR = missing we are not
                # interested because we already know that we have a pending analysis from
                # the PREPC/PRVRE line
                return nothing
            end
        end

    else
        error("Unsupported value[$ana_code] in column ANA_CODE")
    end

    return(
        request = request,
        result = result
    )

end
