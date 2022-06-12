mutable struct OutbreakConfigUnitAsso <: IOutbreakConfigUnitAsso 

  unit::Union{Missing,Model.IUnit}
  outbreakConfig::Union{Missing,Model.IOutbreakConfig}
  id::Union{Missing,String}
  startDate::Union{Missing,Date}
  endDate::Union{Missing,Date}

  OutbreakConfigUnitAsso(args::NamedTuple) = OutbreakConfigUnitAsso(;args...)
  OutbreakConfigUnitAsso(;
    unit = missing,
    outbreakConfig = missing,
    id = missing,
    startDate = missing,
    endDate = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,)
    x.unit = unit
    x.outbreakConfig = outbreakConfig
    x.id = id
    x.startDate = startDate
    x.endDate = endDate
    return x
  end

end 