mutable struct OutbreakConfigUnitAsso <: IOutbreakConfigUnitAsso 

  unit::Union{Missing,Model.IUnit}
  outbreakConfig::Union{Missing,Model.IOutbreakConfig}
  id::Union{Missing,String}
  sameRoomOnly::Union{Missing,Bool}
  startDate::Union{Missing,Date}
  endDate::Union{Missing,Date}

  OutbreakConfigUnitAsso(args::NamedTuple) = OutbreakConfigUnitAsso(;args...)
  OutbreakConfigUnitAsso(;
    unit = missing,
    outbreakConfig = missing,
    id = missing,
    sameRoomOnly = missing,
    startDate = missing,
    endDate = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,)
    x.unit = unit
    x.outbreakConfig = outbreakConfig
    x.id = id
    x.sameRoomOnly = sameRoomOnly
    x.startDate = startDate
    x.endDate = endDate
    return x
  end

end 