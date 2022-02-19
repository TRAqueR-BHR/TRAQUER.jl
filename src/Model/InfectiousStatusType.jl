mutable struct InfectiousStatusType <: IInfectiousStatusType 

  id::Union{Missing,String}
  nameFr::Union{Missing,String}
  codeName::Union{Missing,String}
  nameEn::Union{Missing,String}
  infectiousStatuses::Union{Missing,Vector{Model.IInfectiousStatus}}

  InfectiousStatusType(args::NamedTuple) = InfectiousStatusType(;args...)
  InfectiousStatusType(;
    id = missing,
    nameFr = missing,
    codeName = missing,
    nameEn = missing,
    infectiousStatuses = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,);
    x.id = id;
    x.nameFr = nameFr;
    x.codeName = codeName;
    x.nameEn = nameEn;
    x.infectiousStatuses = infectiousStatuses;
    return x
  )

end 