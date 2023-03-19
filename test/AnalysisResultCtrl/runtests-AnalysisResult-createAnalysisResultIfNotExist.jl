include("../runtests-prerequisite.jl")

@testset "Test AnalysisResult.createAnalysisResultIfNotExist" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn

        unit = UnitCtrl.createUnitIfNotExists(
            randstring(6), # unitCodeName::String,
            randstring(6), # unitName::String,
            dbconn)

        patient = PatientCtrl.createPatientIfNoExist(
            randstring(6), # firstname
            randstring(6), # lastname
            Date("1978-09-12"),
            rand(Int32) |> abs |> string, # hospital ref
            getDefaultEncryptionStr(),
            dbconn)

        stay = StayCtrl.upsert!(
            patient,
            unit,
            now(getTimeZone()) - Day(2), # inTime::ZonedDateTime,
            now(getTimeZone()) + Day(2), # outTime::Union{Missing,ZonedDateTime},
            now(getTimeZone()), # hospitalizationInTime::ZonedDateTime,
            now(getTimeZone()), # hospitalizationOutTime::Union{Missing,ZonedDateTime},
            dbconn)

        analysisResult = AnalysisResultCtrl.createAnalysisResultIfNotExist(
            patient,
            stay,
            AnalysisRequestType.molecular_analysis, # request::ANALYSIS_REQUEST_TYPE,
            now(getTimeZone()), # requestTime::ZonedDateTime,
            randstring(6), # ref::String,
            getDefaultEncryptionStr(),
            SampleMaterialType.faeces, # sample::Union{Missing,SAMPLE_MATERIAL_TYPE},
            AnalysisResultValueType.klebsiella_pneumoniae, #value::Union{Missing,ANALYSIS_RESULT_VALUE_TYPE},
            dbconn
        )

        PostgresORM.delete_entity(analysisResult, dbconn)
        PostgresORM.delete_entity(stay, dbconn)
        PostgresORM.delete_entity(patient, dbconn)
        PostgresORM.delete_entity(unit, dbconn)

    end

end
