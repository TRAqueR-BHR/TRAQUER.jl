mutable struct Role <: IRole 

  id::Union{Missing,String}
  composed::Union{Missing,Bool}
  nameFr::Union{Missing,String}
  codeName::Union{Missing,RoleCodeName.ROLE_CODE_NAME}
  nameEn::Union{Missing,String}
  restrictedToAppuserType::Union{Missing,AppuserType.APPUSER_TYPE}
  appuserRoleAssoes::Union{Missing,Vector{Model.IAppuserRoleAsso}}
  handlerRoleRoleRoleAssoes::Union{Missing,Vector{Model.IRoleRoleAsso}}
  handledRoleRoleRoleAssoes::Union{Missing,Vector{Model.IRoleRoleAsso}}

  Role(args::NamedTuple) = Role(;args...)
  Role(;
    id = missing,
    composed = missing,
    nameFr = missing,
    codeName = missing,
    nameEn = missing,
    restrictedToAppuserType = missing,
    appuserRoleAssoes = missing,
    handlerRoleRoleRoleAssoes = missing,
    handledRoleRoleRoleAssoes = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,);
    x.id = id;
    x.composed = composed;
    x.nameFr = nameFr;
    x.codeName = codeName;
    x.nameEn = nameEn;
    x.restrictedToAppuserType = restrictedToAppuserType;
    x.appuserRoleAssoes = appuserRoleAssoes;
    x.handlerRoleRoleRoleAssoes = handlerRoleRoleRoleAssoes;
    x.handledRoleRoleRoleAssoes = handledRoleRoleRoleAssoes;
    return x
  )

end 