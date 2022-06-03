mutable struct Stay <: IStay 

  patient::Union{Missing,Model.IPatient}
  unit::Union{Missing,Model.IUnit}
  id::Union{Missing,String}
  inDate::Union{Missing,Date}
  hospitalizationOutTime::Union{Missing,ZonedDateTime}
  inTime::Union{Missing,ZonedDateTime}
  outTime::Union{Missing,ZonedDateTime}
  hospitalizationInTime::Union{Missing,ZonedDateTime}
  room::Union{Missing,String}
  analysisResults::Union{Missing,Vector{Model.IAnalysisResult}}

  Stay(args::NamedTuple) = Stay(;args...)
  Stay(;
    patient = missing,
    unit = missing,
    id = missing,
    inDate = missing,
    hospitalizationOutTime = missing,
    inTime = missing,
    outTime = missing,
    hospitalizationInTime = missing,
    room = missing,
    analysisResults = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.unit = unit
    x.id = id
    x.inDate = inDate
    x.hospitalizationOutTime = hospitalizationOutTime
    x.inTime = inTime
    x.outTime = outTime
    x.hospitalizationInTime = hospitalizationInTime
    x.room = room
    x.analysisResults = analysisResults
    return x
  end

end 