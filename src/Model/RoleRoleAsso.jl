mutable struct RoleRoleAsso <: IRoleRoleAsso 

  handlerRole::Union{Missing,Model.IRole}
  handledRole::Union{Missing,Model.IRole}
  id::Union{Missing,String}

  RoleRoleAsso(args::NamedTuple) = RoleRoleAsso(;args...)
  RoleRoleAsso(;
    handlerRole = missing,
    handledRole = missing,
    id = missing,
  ) = begin
    x = new(missing,missing,missing,)
    x.handlerRole = handlerRole
    x.handledRole = handledRole
    x.id = id
    return x
  end

end 