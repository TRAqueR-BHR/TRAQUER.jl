mutable struct AnalysisResult <: IAnalysisResult 

  patient::Union{Missing,Model.IPatient}
  stay::Union{Missing,Model.IStay}
  analysisRefCrypt::Union{Missing,Model.IAnalysisRefCrypt}
  id::Union{Missing,String}
  sampleMaterialType::Union{Missing,SampleMaterialType.SAMPLE_MATERIAL_TYPE}
  requestTime::Union{Missing,ZonedDateTime}
  sysCreationTime::Union{Missing,ZonedDateTime}
  resultTime::Union{Missing,ZonedDateTime}
  result::Union{Missing,AnalysisResultValueType.ANALYSIS_RESULT_VALUE_TYPE}
  resultRawText::Union{Missing,String}
  requestType::Union{Missing,AnalysisRequestType.ANALYSIS_REQUEST_TYPE}
  sysProcessingTime::Union{Missing,ZonedDateTime}

  AnalysisResult(args::NamedTuple) = AnalysisResult(;args...)
  AnalysisResult(;
    patient = missing,
    stay = missing,
    analysisRefCrypt = missing,
    id = missing,
    sampleMaterialType = missing,
    requestTime = missing,
    sysCreationTime = missing,
    resultTime = missing,
    result = missing,
    resultRawText = missing,
    requestType = missing,
    sysProcessingTime = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.stay = stay
    x.analysisRefCrypt = analysisRefCrypt
    x.id = id
    x.sampleMaterialType = sampleMaterialType
    x.requestTime = requestTime
    x.sysCreationTime = sysCreationTime
    x.resultTime = resultTime
    x.result = result
    x.resultRawText = resultRawText
    x.requestType = requestType
    x.sysProcessingTime = sysProcessingTime
    return x
  end

end 