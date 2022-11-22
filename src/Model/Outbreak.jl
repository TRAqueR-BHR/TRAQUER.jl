mutable struct Outbreak <: IOutbreak 

  creator::Union{Missing,Model.IAppuser}
  id::Union{Missing,String}
  criticity::Union{Missing,OutbreakCriticity.OUTBREAK_CRITICITY}
  name::Union{Missing,String}
  infectiousAgent::Union{Missing,InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}
  refTime::Union{Missing,ZonedDateTime}
  outbreakUnitAssoes::Union{Missing,Vector{Model.IOutbreakUnitAsso}}
  contactExposures::Union{Missing,Vector{Model.IContactExposure}}
  outbreakInfectiousStatusAssoes::Union{Missing,Vector{Model.IOutbreakInfectiousStatusAsso}}

  Outbreak(args::NamedTuple) = Outbreak(;args...)
  Outbreak(;
    creator = missing,
    id = missing,
    criticity = missing,
    name = missing,
    infectiousAgent = missing,
    refTime = missing,
    outbreakUnitAssoes = missing,
    contactExposures = missing,
    outbreakInfectiousStatusAssoes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.creator = creator
    x.id = id
    x.criticity = criticity
    x.name = name
    x.infectiousAgent = infectiousAgent
    x.refTime = refTime
    x.outbreakUnitAssoes = outbreakUnitAssoes
    x.contactExposures = contactExposures
    x.outbreakInfectiousStatusAssoes = outbreakInfectiousStatusAssoes
    return x
  end

end 