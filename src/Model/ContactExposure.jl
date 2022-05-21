mutable struct ContactExposure <: IContactExposure 

  unit::Union{Missing,Model.IUnit}
  contact::Union{Missing,Model.IPatient}
  carrier::Union{Missing,Model.IPatient}
  id::Union{Missing,String}
  startDate::Union{Missing,Date}
  startTime::Union{Missing,ZonedDateTime}
  endTime::Union{Missing,ZonedDateTime}
  endDate::Union{Missing,Date}

  ContactExposure(args::NamedTuple) = ContactExposure(;args...)
  ContactExposure(;
    unit = missing,
    contact = missing,
    carrier = missing,
    id = missing,
    startDate = missing,
    startTime = missing,
    endTime = missing,
    endDate = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,)
    x.unit = unit
    x.contact = contact
    x.carrier = carrier
    x.id = id
    x.startDate = startDate
    x.startTime = startTime
    x.endTime = endTime
    x.endDate = endDate
    return x
  end

end 