mutable struct FctUnitStay <: IFctUnitStay 

  fctUnit::Union{Missing,Model.IFctUnit}
  patient::Union{Missing,Model.IPatient}
  id::Union{Missing,String}
  outDateTime::Union{Missing,ZonedDateTime}
  inDateTime::Union{Missing,ZonedDateTime}

  FctUnitStay(args::NamedTuple) = FctUnitStay(;args...)
  FctUnitStay(;
    fctUnit = missing,
    patient = missing,
    id = missing,
    outDateTime = missing,
    inDateTime = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,);
    x.fctUnit = fctUnit;
    x.patient = patient;
    x.id = id;
    x.outDateTime = outDateTime;
    x.inDateTime = inDateTime;
    return x
  )

end 