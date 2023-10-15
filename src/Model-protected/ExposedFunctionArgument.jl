mutable struct ExposedFunctionArgument <: IExposedFunctionArgument

  rank::Union{Missing,Int16}
  prettyName::Union{Missing,String}
  juliaTypeName::Union{Missing,String}
  isDatabaseCryptPwd::Union{Missing,Bool}
  isCurrentUser::Union{Missing,Bool}
  value::Union{Missing,Any}

  ExposedFunctionArgument(args::NamedTuple) = ExposedFunctionArgument(;args...)
  ExposedFunctionArgument(;
    rank = missing,
    prettyName = missing,
    juliaTypeName = missing,
    isDatabaseCryptPwd = missing,
    isCurrentUser = missing,
    value = missing
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,)
    x.rank = rank
    x.prettyName = prettyName
    x.juliaTypeName = juliaTypeName
    x.isDatabaseCryptPwd = isDatabaseCryptPwd
    x.isCurrentUser = isCurrentUser
    x.value = value
    return x
  end

end
