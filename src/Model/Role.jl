mutable struct Role <: IRole 

  id::Union{Missing,String}
  composed::Union{Missing,Bool}
  codeName::Union{Missing,RoleCodeName.ROLE_CODE_NAME}
  restrictedToAppuserType::Union{Missing,AppuserType.APPUSER_TYPE}
  appuserRoleAssoes::Union{Missing,Vector{Model.IAppuserRoleAsso}}
  handlerRoleRoleRoleAssoes::Union{Missing,Vector{Model.IRoleRoleAsso}}
  handledRoleRoleRoleAssoes::Union{Missing,Vector{Model.IRoleRoleAsso}}

  Role(args::NamedTuple) = Role(;args...)
  Role(;
    id = missing,
    composed = missing,
    codeName = missing,
    restrictedToAppuserType = missing,
    appuserRoleAssoes = missing,
    handlerRoleRoleRoleAssoes = missing,
    handledRoleRoleRoleAssoes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.composed = composed
    x.codeName = codeName
    x.restrictedToAppuserType = restrictedToAppuserType
    x.appuserRoleAssoes = appuserRoleAssoes
    x.handlerRoleRoleRoleAssoes = handlerRoleRoleRoleAssoes
    x.handledRoleRoleRoleAssoes = handledRoleRoleRoleAssoes
    return x
  end

end 