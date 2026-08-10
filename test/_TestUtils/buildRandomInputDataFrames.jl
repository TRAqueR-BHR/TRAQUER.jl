"""
    _TestUtils.buildInputDataFrames(;nbPatients::Integer = 10)

Generate two random input DataFrames for testing purposes: one for stays and one for
analyses.

The number of patients can be specified with the `nbPatients` parameter.

Columns for the stays DataFrame:
patient_ref -> String
firstname -> String
lastname -> String
birthdate -> Date
hospitalization_in_time -> ZonedDateTime
hospitalization_out_time -> Union{Missing, ZonedDateTime}
unit_code_name -> String
unit_name -> String
sector -> Union{Missing, String}
room -> String
unit_in_time -> ZonedDateTime
unit_out_time -> Union{Missing, ZonedDateTime}
patient_died_during_stay -> Bool

Columns for the analyses DataFrame:
patient_ref -> String
firstname -> String
lastname -> String
birthdate -> Date
analysis_ref -> String
status -> String
request_time -> ZonedDateTime
result_time -> Union{Missing, ZonedDateTime}
sample -> SAMPLE_MATERIAL_TYPE
request_type -> ANALYSIS_REQUEST_TYPE
result -> Union{Missing, ANALYSIS_RESULT_VALUE_TYPE}
"""
function _TestUtils.buildInputDataFrames(;nbPatients::Integer = 10)
    if nbPatients < 0
        throw(ArgumentError("nbPatients must be non-negative"))
    end

    staysRows = NamedTuple[]
    analysesRows = NamedTuple[]

    for patientIdx in 1:nbPatients
        patient = (
            patient_ref = _TestUtils.buildRandomPatientRef(),
            firstname = _TestUtils.buildRandomPatientFirstname(),
            lastname = _TestUtils.buildRandomPatientLastname(),
            birthdate = _TestUtils.buildRandomPatientBirthdate(),
        )

        patientStays = Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}[]
        nbHospitalizations = rand(1:3)
        hospitalizations = _TestUtils.buildRandomHospitalizationsDateTimes(
            patient.birthdate,
            nbHospitalizations,
        )

        for (hospitalizationIdx, hospitalization) in enumerate(hospitalizations)
            nbStays = rand(1:4)
            stays = _TestUtils.buildRandomStaysDateTimes(hospitalization, nbStays)
            append!(patientStays, stays)

            for (stayIdx, stay) in enumerate(stays)
                unitNumber = mod1(patientIdx + hospitalizationIdx + stayIdx, 10)

                push!(
                    staysRows,
                    (
                        patient_ref = patient.patient_ref,
                        firstname = patient.firstname,
                        lastname = patient.lastname,
                        birthdate = patient.birthdate,
                        hospitalization_in_time = first(hospitalization),
                        hospitalization_out_time = last(hospitalization),
                        unit_code_name = "UNIT_$(unitNumber)",
                        unit_name = "Unit $(unitNumber)",
                        sector = rand() < 0.5 ? missing : "SECTOR_$(rand(1:4))",
                        room = "ROOM_$(rand(1:40))",
                        unit_in_time = first(stay),
                        unit_out_time = last(stay),
                        patient_died_during_stay = false,
                    ),
                )
            end
        end

        nbAnalyses = rand(1:5)
        for _ in 1:nbAnalyses
            # Most generated analyses should fall inside one of the patient's stays.
            analysisDateTime = if rand() < 0.7
                _TestUtils.buildRandomAnalysisDateTime(patientStays)
            else
                _TestUtils.buildRandomAnalysisDateTimeOutsideStays(patient.birthdate)
            end
            resultTime = last(analysisDateTime)
            analysisResult = if ismissing(resultTime)
                missing
            else
                rand(instances(ANALYSIS_RESULT_VALUE_TYPE))
            end

            push!(
                analysesRows,
                (
                    patient_ref = patient.patient_ref,
                    firstname = patient.firstname,
                    lastname = patient.lastname,
                    birthdate = patient.birthdate,
                    analysis_ref = _TestUtils.buildRandomAnalysisRef(),
                    status = ismissing(resultTime) ? "requested" : "done",
                    request_time = first(analysisDateTime),
                    result_time = resultTime,
                    sample = rand(instances(SAMPLE_MATERIAL_TYPE)),
                    request_type = rand(instances(ANALYSIS_REQUEST_TYPE)),
                    result = analysisResult,
                ),
            )
        end
    end

    staysDf = if isempty(staysRows)
        _TestUtils.buildEmptyStaysDataFrame()
    else
        DataFrame(staysRows)
    end
    analysesDf = if isempty(analysesRows)
        _TestUtils.buildEmptyAnalysesDataFrame()
    else
        DataFrame(analysesRows)
    end

    return (stays = staysDf, analyses = analysesDf)
end

