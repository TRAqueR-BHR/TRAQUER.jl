mutable struct Modification <: IModification 

  id::Union{Missing,String}
  newvalue::Union{Missing,String}
  oldvalue::Union{Missing,String}
  actionId::Union{Missing,String}
  creationTime::Union{Missing,DateTime}
  actionType::Union{Missing,String}
  attrname::Union{Missing,String}
  userId::Union{Missing,String}
  entityType::Union{Missing,String}
  entityId::Union{Missing,String}

  Modification(args::NamedTuple) = Modification(;args...)
  Modification(;
    id = missing,
    newvalue = missing,
    oldvalue = missing,
    actionId = missing,
    creationTime = missing,
    actionType = missing,
    attrname = missing,
    userId = missing,
    entityType = missing,
    entityId = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.newvalue = newvalue
    x.oldvalue = oldvalue
    x.actionId = actionId
    x.creationTime = creationTime
    x.actionType = actionType
    x.attrname = attrname
    x.userId = userId
    x.entityType = entityType
    x.entityId = entityId
    return x
  end

end 