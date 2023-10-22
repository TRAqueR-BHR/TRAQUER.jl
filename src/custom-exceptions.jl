export OutbreakNameAlreadyUsedError
struct OutbreakNameAlreadyUsedError <: Exception
    msg::AbstractString
end
export NoStayFoundError
struct NoStayFoundError <: Exception
    msg::AbstractString
end
