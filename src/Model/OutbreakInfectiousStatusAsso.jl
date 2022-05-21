mutable struct OutbreakInfectiousStatusAsso <: IOutbreakInfectiousStatusAsso 

  outbreak::Union{Missing,Model.IOutbreak}
  infectiousStatus::Union{Missing,Model.IInfectiousStatus}
  id::Union{Missing,String}

  OutbreakInfectiousStatusAsso(args::NamedTuple) = OutbreakInfectiousStatusAsso(;args...)
  OutbreakInfectiousStatusAsso(;
    outbreak = missing,
    infectiousStatus = missing,
    id = missing,
  ) = begin
    x = new(missing,missing,missing,)
    x.outbreak = outbreak
    x.infectiousStatus = infectiousStatus
    x.id = id
    return x
  end

end 