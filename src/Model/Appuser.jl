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
  lastEditorAppuserRoleAssoes::Union{Missing,Vector{Model.IAppuserRoleAsso}}
  appuserAppuserRoleAssoes::Union{Missing,Vector{Model.IAppuserRoleAsso}}
  creatorAppuserRoleAssoes::Union{Missing,Vector{Model.IAppuserRoleAsso}}
  creatorAppusers::Union{Missing,Vector{Model.IAppuser}}
  lastEditorAppusers::Union{Missing,Vector{Model.IAppuser}}

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
    lastEditorAppuserRoleAssoes = missing,
    appuserAppuserRoleAssoes = missing,
    creatorAppuserRoleAssoes = missing,
    creatorAppusers = missing,
    lastEditorAppusers = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,);
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
    x.lastEditorAppuserRoleAssoes = lastEditorAppuserRoleAssoes;
    x.appuserAppuserRoleAssoes = appuserAppuserRoleAssoes;
    x.creatorAppuserRoleAssoes = creatorAppuserRoleAssoes;
    x.creatorAppusers = creatorAppusers;
    x.lastEditorAppusers = lastEditorAppusers;
    return x
  )

end 