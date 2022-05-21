mutable struct Stay <: IStay 

  patient::Union{Missing,Model.IPatient}
  unit::Union{Missing,Model.IUnit}
  id::Union{Missing,String}
  inDate::Union{Missing,Date}
  hospitalizationDate::Union{Missing,Date}
  outDateTime::Union{Missing,ZonedDateTime}
  inDateTime::Union{Missing,ZonedDateTime}
  analyses::Union{Missing,Vector{Model.IAnalysis}}

  Stay(args::NamedTuple) = Stay(;args...)
  Stay(;
    patient = missing,
    unit = missing,
    id = missing,
    inDate = missing,
    hospitalizationDate = missing,
    outDateTime = missing,
    inDateTime = missing,
    analyses = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.unit = unit
    x.id = id
    x.inDate = inDate
    x.hospitalizationDate = hospitalizationDate
    x.outDateTime = outDateTime
    x.inDateTime = inDateTime
    x.analyses = analyses
    return x
  end

end 