mutable struct Appuser <: IAppuser

  creator::Union{Missing,Model.IAppuser}
  lastEditor::Union{Missing,Model.IAppuser}
  id::Union{Missing,String}
  login::Union{Missing,String}
  email::Union{Missing,String}
  firstname::Union{Missing,String}
  appuserType::Union{Missing,AppuserType.APPUSER_TYPE}
  languageCode::Union{Missing,String}
  password::Union{Missing,String}
  creationTime::Union{Missing,DateTime}
  avatarId::Union{Missing,String}
  lastname::Union{Missing,String}
  preferences::Union{Missing,String}
  deactivated::Union{Missing,Bool}
  updateTime::Union{Missing,DateTime}
  appuserAppuserRoleAssoes::Union{Missing,Vector{Model.IAppuserRoleAsso}}

  # Convenience attribute for storing all the roles of the appuser (the
  # composed and their children).
  # NOTE: not persisted to database
  allRoles::Union{Missing,Vector{Model.IRole}}
  jwt::Union{Missing,String}



  Appuser(args::NamedTuple) = Appuser(;args...)
  Appuser(;
    creator = missing,
    lastEditor = missing,
    id = missing,
    login = missing,
    email = missing,
    firstname = missing,
    appuserType = missing,
    languageCode = missing,
    password = missing,
    creationTime = missing,
    avatarId = missing,
    lastname = missing,
    preferences = missing,
    deactivated = missing,
    updateTime = missing,
    appuserAppuserRoleAssoes = missing,
    allRoles = missing,
    jwt = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,);
    x.creator = creator;
    x.lastEditor = lastEditor;
    x.id = id;
    x.login = login;
    x.email = email;
    x.firstname = firstname;
    x.appuserType = appuserType;
    x.languageCode = languageCode;
    x.password = password;
    x.creationTime = creationTime;
    x.avatarId = avatarId;
    x.lastname = lastname;
    x.preferences = preferences;
    x.deactivated = deactivated;
    x.updateTime = updateTime;
    x.appuserAppuserRoleAssoes = appuserAppuserRoleAssoes;
    x.allRoles = allRoles;
    x.jwt = jwt;

    return x
  )

end
