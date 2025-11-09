"""
    Custom.getAnalysisRefOneChar(ref::String)::String

Return the last character of the analysis file as known by the hospital.
NOTE: The analysis ref is composed of the following:
    analysis_file * sample_nb * "_" * ANA_CODE
Eg. 8000000003      02           _    ATB2

"""
function Custom.getAnalysisRefOneChar(ref::String)::String

    if (length(ref) >= 10)
        return ref[10] |> string
    else
        return last(ref) |> string
    end
end
