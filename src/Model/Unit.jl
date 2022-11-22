mutable struct Unit <: IUnit 

  id::Union{Missing,String}
  name::Union{Missing,String}
  codeName::Union{Missing,String}
  outbreakUnitAssoes::Union{Missing,Vector{Model.IOutbreakUnitAsso}}
  contactExposures::Union{Missing,Vector{Model.IContactExposure}}
  staies::Union{Missing,Vector{Model.IStay}}
  patients::Union{Missing,Vector{Model.IPatient}}
  analysisRequests::Union{Missing,Vector{Model.IAnalysisRequest}}

  Unit(args::NamedTuple) = Unit(;args...)
  Unit(;
    id = missing,
    name = missing,
    codeName = missing,
    outbreakUnitAssoes = missing,
    contactExposures = missing,
    staies = missing,
    patients = missing,
    analysisRequests = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.name = name
    x.codeName = codeName
    x.outbreakUnitAssoes = outbreakUnitAssoes
    x.contactExposures = contactExposures
    x.staies = staies
    x.patients = patients
    x.analysisRequests = analysisRequests
    return x
  end

end 