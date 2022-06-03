mutable struct ContactExposure <: IContactExposure 

  unit::Union{Missing,Model.IUnit}
  contact::Union{Missing,Model.IPatient}
  carrier::Union{Missing,Model.IPatient}
  id::Union{Missing,String}
  startTime::Union{Missing,ZonedDateTime}
  endTime::Union{Missing,ZonedDateTime}

  ContactExposure(args::NamedTuple) = ContactExposure(;args...)
  ContactExposure(;
    unit = missing,
    contact = missing,
    carrier = missing,
    id = missing,
    startTime = missing,
    endTime = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,)
    x.unit = unit
    x.contact = contact
    x.carrier = carrier
    x.id = id
    x.startTime = startTime
    x.endTime = endTime
    return x
  end

end 