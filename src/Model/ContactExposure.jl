mutable struct ContactExposure <: IContactExposure 

  unit::Union{Missing,Model.IUnit}
  contact::Union{Missing,Model.IPatient}
  carrier::Union{Missing,Model.IPatient}
  outbreak::Union{Missing,Model.IOutbreak}
  id::Union{Missing,String}
  startTime::Union{Missing,ZonedDateTime}
  endTime::Union{Missing,ZonedDateTime}
  infectiousStatuses::Union{Missing,Vector{Model.IInfectiousStatus}}

  ContactExposure(args::NamedTuple) = ContactExposure(;args...)
  ContactExposure(;
    unit = missing,
    contact = missing,
    carrier = missing,
    outbreak = missing,
    id = missing,
    startTime = missing,
    endTime = missing,
    infectiousStatuses = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,)
    x.unit = unit
    x.contact = contact
    x.carrier = carrier
    x.outbreak = outbreak
    x.id = id
    x.startTime = startTime
    x.endTime = endTime
    x.infectiousStatuses = infectiousStatuses
    return x
  end

end 