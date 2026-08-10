"""
    _TestUtils.buildEmptyAnalysesDataFrame()::DataFrame

Build an empty analyses input DataFrame with the expected columns and column types.
"""
function _TestUtils.buildEmptyAnalysesDataFrame()::DataFrame
    return DataFrame(
        patient_ref = String[],
        firstname = String[],
        lastname = String[],
        birthdate = Date[],
        analysis_ref = String[],
        status = String[],
        request_time = ZonedDateTime[],
        result_time = Union{Missing,ZonedDateTime}[],
        sample = SAMPLE_MATERIAL_TYPE[],
        request_type = ANALYSIS_REQUEST_TYPE[],
        result = Union{Missing,ANALYSIS_RESULT_VALUE_TYPE}[],
    )
end
