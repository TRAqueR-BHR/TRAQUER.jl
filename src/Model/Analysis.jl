mutable struct Analysis <: IAnalysis 

  patient::Union{Missing,Model.IPatient}
  stay::Union{Missing,Model.IStay}
  analysisRefCrypt::Union{Missing,Model.IAnalysisRefCrypt}
  analysisType::Union{Missing,Model.IAnalysisType}
  id::Union{Missing,String}
  requestDateTime::Union{Missing,ZonedDateTime}
  sampleType::Union{Missing,String}
  resultValue::Union{Missing,String}

  Analysis(args::NamedTuple) = Analysis(;args...)
  Analysis(;
    patient = missing,
    stay = missing,
    analysisRefCrypt = missing,
    analysisType = missing,
    id = missing,
    requestDateTime = missing,
    sampleType = missing,
    resultValue = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,);
    x.patient = patient;
    x.stay = stay;
    x.analysisRefCrypt = analysisRefCrypt;
    x.analysisType = analysisType;
    x.id = id;
    x.requestDateTime = requestDateTime;
    x.sampleType = sampleType;
    x.resultValue = resultValue;
    return x
  )

end 