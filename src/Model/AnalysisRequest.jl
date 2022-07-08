mutable struct AnalysisRequest <: IAnalysisRequest 

  creator::Union{Missing,Model.IAppuser}
  lastEditor::Union{Missing,Model.IAppuser}
  id::Union{Missing,String}
  requestType::Union{Missing,AnalysisRequestType.ANALYSIS_REQUEST_TYPE}
  creationTime::Union{Missing,ZonedDateTime}
  lastUpdateTime::Union{Missing,ZonedDateTime}
  statusType::Union{Missing,AnalysisRequestStatusType.ANALYSIS_REQUEST_STATUS_TYPE}

  AnalysisRequest(args::NamedTuple) = AnalysisRequest(;args...)
  AnalysisRequest(;
    creator = missing,
    lastEditor = missing,
    id = missing,
    requestType = missing,
    creationTime = missing,
    lastUpdateTime = missing,
    statusType = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,)
    x.creator = creator
    x.lastEditor = lastEditor
    x.id = id
    x.requestType = requestType
    x.creationTime = creationTime
    x.lastUpdateTime = lastUpdateTime
    x.statusType = statusType
    return x
  end

end 