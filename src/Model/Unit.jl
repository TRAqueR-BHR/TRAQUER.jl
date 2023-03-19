mutable struct Unit <: IUnit 

  id::Union{Missing,String}
  name::Union{Missing,String}
  codeName::Union{Missing,String}
  outbreakUnitAssoes::Union{Missing,Vector{Model.IOutbreakUnitAsso}}
  staies::Union{Missing,Vector{Model.IStay}}
  contactExposures::Union{Missing,Vector{Model.IContactExposure}}
  patients::Union{Missing,Vector{Model.IPatient}}
  analysisRequests::Union{Missing,Vector{Model.IAnalysisRequest}}

  Unit(args::NamedTuple) = Unit(;args...)
  Unit(;
    id = missing,
    name = missing,
    codeName = missing,
    outbreakUnitAssoes = missing,
    staies = missing,
    contactExposures = missing,
    patients = missing,
    analysisRequests = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.name = name
    x.codeName = codeName
    x.outbreakUnitAssoes = outbreakUnitAssoes
    x.staies = staies
    x.contactExposures = contactExposures
    x.patients = patients
    x.analysisRequests = analysisRequests
    return x
  end

end 