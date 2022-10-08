mutable struct OutbreakConfigUnitAsso <: IOutbreakConfigUnitAsso 

  creator::Union{Missing,Model.IAppuser}
  unit::Union{Missing,Model.IUnit}
  outbreakConfig::Union{Missing,Model.IOutbreakConfig}
  id::Union{Missing,String}
  startTime::Union{Missing,ZonedDateTime}
  endTime::Union{Missing,ZonedDateTime}
  isDefault::Union{Missing,Bool}
  comment::Union{Missing,String}

  OutbreakConfigUnitAsso(args::NamedTuple) = OutbreakConfigUnitAsso(;args...)
  OutbreakConfigUnitAsso(;
    creator = missing,
    unit = missing,
    outbreakConfig = missing,
    id = missing,
    startTime = missing,
    endTime = missing,
    isDefault = missing,
    comment = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,)
    x.creator = creator
    x.unit = unit
    x.outbreakConfig = outbreakConfig
    x.id = id
    x.startTime = startTime
    x.endTime = endTime
    x.isDefault = isDefault
    x.comment = comment
    return x
  end

end 