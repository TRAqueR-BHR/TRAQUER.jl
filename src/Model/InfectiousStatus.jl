mutable struct InfectiousStatus <: IInfectiousStatus 

  patient::Union{Missing,Model.IPatient}
  type::Union{Missing,Model.IInfectiousStatusType}
  id::Union{Missing,String}
  creationTime::Union{Missing,ZonedDateTime}
  carrierContact::Union{Missing,CarrierContact.CARRIER_CONTACT}
  refTime::Union{Missing,ZonedDateTime}

  InfectiousStatus(args::NamedTuple) = InfectiousStatus(;args...)
  InfectiousStatus(;
    patient = missing,
    type = missing,
    id = missing,
    creationTime = missing,
    carrierContact = missing,
    refTime = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,);
    x.patient = patient;
    x.type = type;
    x.id = id;
    x.creationTime = creationTime;
    x.carrierContact = carrierContact;
    x.refTime = refTime;
    return x
  )

end 