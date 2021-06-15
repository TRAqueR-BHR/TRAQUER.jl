mutable struct LabAnalysis <: ILabAnalysis 

  patient::Union{Missing,Model.IPatient}
  id::Union{Missing,String}
  bmr::Union{Missing,String}
  requestDate::Union{Missing,ZonedDateTime}
  fctUnitStayId::Union{Missing,String}
  analysisType::Union{Missing,String}
  sampleType::Union{Missing,String}
  resultValue::Union{Missing,String}
  result::Union{Missing,String}

  LabAnalysis(args::NamedTuple) = LabAnalysis(;args...)
  LabAnalysis(;
    patient = missing,
    id = missing,
    bmr = missing,
    requestDate = missing,
    fctUnitStayId = missing,
    analysisType = missing,
    sampleType = missing,
    resultValue = missing,
    result = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,);
    x.patient = patient;
    x.id = id;
    x.bmr = bmr;
    x.requestDate = requestDate;
    x.fctUnitStayId = fctUnitStayId;
    x.analysisType = analysisType;
    x.sampleType = sampleType;
    x.resultValue = resultValue;
    x.result = result;
    return x
  )

end 