mutable struct ExposedFunction <: IExposedFunction 

  id::Union{Missing,String}
  prettyName::Union{Missing,String}
  roles::Union{Missing,Vector{RoleCodeName.ROLE_CODE_NAME}}
  juliaName::Union{Missing,String}
  argumentsAsJson::Union{Missing,String}

  ExposedFunction(args::NamedTuple) = ExposedFunction(;args...)
  ExposedFunction(;
    id = missing,
    prettyName = missing,
    roles = missing,
    juliaName = missing,
    argumentsAsJson = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,)
    x.id = id
    x.prettyName = prettyName
    x.roles = roles
    x.juliaName = juliaName
    x.argumentsAsJson = argumentsAsJson
    return x
  end

end 