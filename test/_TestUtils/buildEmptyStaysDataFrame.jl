"""
    _TestUtils.buildEmptyStaysDataFrame()::DataFrame

Build an empty stays input DataFrame with the expected columns and column types.
"""
function _TestUtils.buildEmptyStaysDataFrame()::DataFrame
    return DataFrame(
        patient_ref = String[],
        firstname = String[],
        lastname = String[],
        birthdate = Date[],
        hospitalization_in_time = ZonedDateTime[],
        hospitalization_out_time = Union{Missing,ZonedDateTime}[],
        unit_code_name = String[],
        unit_name = String[],
        sector = Union{Missing,String}[],
        room = String[],
        unit_in_time = ZonedDateTime[],
        unit_out_time = Union{Missing,ZonedDateTime}[],
        patient_died_during_stay = Bool[],
    )
end
