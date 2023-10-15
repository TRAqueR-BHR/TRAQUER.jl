mutable struct AnalysisRequest <: IAnalysisRequest 

  creator::Union{Missing,Model.IAppuser}
  patient::Union{Missing,Model.IPatient}
  lastEditor::Union{Missing,Model.IAppuser}
  unit::Union{Missing,Model.IUnit}
  id::Union{Missing,String}
  unitExpectedCollectionTime::Union{Missing,ZonedDateTime}
  requestTime::Union{Missing,ZonedDateTime}
  status::Union{Missing,AnalysisRequestStatusType.ANALYSIS_REQUEST_STATUS_TYPE}
  requestType::Union{Missing,AnalysisRequestType.ANALYSIS_REQUEST_TYPE}

  AnalysisRequest(args::NamedTuple) = AnalysisRequest(;args...)
  AnalysisRequest(;
    creator = missing,
    patient = missing,
    lastEditor = missing,
    unit = missing,
    id = missing,
    unitExpectedCollectionTime = missing,
    requestTime = missing,
    status = missing,
    requestType = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.creator = creator
    x.patient = patient
    x.lastEditor = lastEditor
    x.unit = unit
    x.id = id
    x.unitExpectedCollectionTime = unitExpectedCollectionTime
    x.requestTime = requestTime
    x.status = status
    x.requestType = requestType
    return x
  end

end 