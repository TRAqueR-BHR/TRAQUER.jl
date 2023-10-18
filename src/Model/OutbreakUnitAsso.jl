mutable struct OutbreakUnitAsso <: IOutbreakUnitAsso 

  unit::Union{Missing,Model.IUnit}
  outbreak::Union{Missing,Model.IOutbreak}
  creator::Union{Missing,Model.IAppuser}
  id::Union{Missing,String}
  startTime::Union{Missing,ZonedDateTime}
  endTime::Union{Missing,ZonedDateTime}
  sameRoomOnly::Union{Missing,Bool}
  sameSectorOnly::Union{Missing,Bool}
  isDefault::Union{Missing,Bool}
  comment::Union{Missing,String}

  OutbreakUnitAsso(args::NamedTuple) = OutbreakUnitAsso(;args...)
  OutbreakUnitAsso(;
    unit = missing,
    outbreak = missing,
    creator = missing,
    id = missing,
    startTime = missing,
    endTime = missing,
    sameRoomOnly = missing,
    sameSectorOnly = missing,
    isDefault = missing,
    comment = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.unit = unit
    x.outbreak = outbreak
    x.creator = creator
    x.id = id
    x.startTime = startTime
    x.endTime = endTime
    x.sameRoomOnly = sameRoomOnly
    x.sameSectorOnly = sameSectorOnly
    x.isDefault = isDefault
    x.comment = comment
    return x
  end

end 