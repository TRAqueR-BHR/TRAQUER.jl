mutable struct FhirXmlError <: IFhirXmlError 

  id::Union{Missing,String}
  fileName::Union{Missing,String}
  createdAt::Union{Missing,ZonedDateTime}
  lineNumber::Union{Missing,Int32}
  errorMessage::Union{Missing,String}

  FhirXmlError(args::NamedTuple) = FhirXmlError(;args...)
  FhirXmlError(;
    id = missing,
    fileName = missing,
    createdAt = missing,
    lineNumber = missing,
    errorMessage = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,)
    x.id = id
    x.fileName = fileName
    x.createdAt = createdAt
    x.lineNumber = lineNumber
    x.errorMessage = errorMessage
    return x
  end

end 