mutable struct AppuserRoleAsso <: IAppuserRoleAsso 

  lastEditor::Union{Missing,Model.IAppuser}
  role::Union{Missing,Model.IRole}
  appuser::Union{Missing,Model.IAppuser}
  creator::Union{Missing,Model.IAppuser}
  id::Union{Missing,String}
  updateTime::Union{Missing,DateTime}
  creationTime::Union{Missing,DateTime}

  AppuserRoleAsso(args::NamedTuple) = AppuserRoleAsso(;args...)
  AppuserRoleAsso(;
    lastEditor = missing,
    role = missing,
    appuser = missing,
    creator = missing,
    id = missing,
    updateTime = missing,
    creationTime = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,missing,);
    x.lastEditor = lastEditor;
    x.role = role;
    x.appuser = appuser;
    x.creator = creator;
    x.id = id;
    x.updateTime = updateTime;
    x.creationTime = creationTime;
    return x
  )

end 