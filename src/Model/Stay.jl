mutable struct Stay <: IStay 

  patient::Union{Missing,Model.IPatient}
  unit::Union{Missing,Model.IUnit}
  id::Union{Missing,String}
  inDate::Union{Missing,Date}
  isolationTime::Union{Missing,ZonedDateTime}
  hospitalizationOutComment::Union{Missing,String}
  outTime::Union{Missing,ZonedDateTime}
  sysCreationTime::Union{Missing,ZonedDateTime}
  patientDiedDuringStay::Union{Missing,Bool}
  hospitalizationOutTime::Union{Missing,ZonedDateTime}
  inTime::Union{Missing,ZonedDateTime}
  hospitalizationInTime::Union{Missing,ZonedDateTime}
  sysProcessingTime::Union{Missing,ZonedDateTime}
  sector::Union{Missing,String}
  room::Union{Missing,String}
  analysisResults::Union{Missing,Vector{Model.IAnalysisResult}}

  Stay(args::NamedTuple) = Stay(;args...)
  Stay(;
    patient = missing,
    unit = missing,
    id = missing,
    inDate = missing,
    isolationTime = missing,
    hospitalizationOutComment = missing,
    outTime = missing,
    sysCreationTime = missing,
    patientDiedDuringStay = missing,
    hospitalizationOutTime = missing,
    inTime = missing,
    hospitalizationInTime = missing,
    sysProcessingTime = missing,
    sector = missing,
    room = missing,
    analysisResults = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.unit = unit
    x.id = id
    x.inDate = inDate
    x.isolationTime = isolationTime
    x.hospitalizationOutComment = hospitalizationOutComment
    x.outTime = outTime
    x.sysCreationTime = sysCreationTime
    x.patientDiedDuringStay = patientDiedDuringStay
    x.hospitalizationOutTime = hospitalizationOutTime
    x.inTime = inTime
    x.hospitalizationInTime = hospitalizationInTime
    x.sysProcessingTime = sysProcessingTime
    x.sector = sector
    x.room = room
    x.analysisResults = analysisResults
    return x
  end

end 