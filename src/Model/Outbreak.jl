mutable struct Outbreak <: IOutbreak 

  config::Union{Missing,Model.IOutbreakConfig}
  creator::Union{Missing,Model.IAppuser}
  id::Union{Missing,String}
  name::Union{Missing,String}
  infectiousAgent::Union{Missing,InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}
  contactExposures::Union{Missing,Vector{Model.IContactExposure}}
  outbreakInfectiousStatusAssoes::Union{Missing,Vector{Model.IOutbreakInfectiousStatusAsso}}

  Outbreak(args::NamedTuple) = Outbreak(;args...)
  Outbreak(;
    config = missing,
    creator = missing,
    id = missing,
    name = missing,
    infectiousAgent = missing,
    contactExposures = missing,
    outbreakInfectiousStatusAssoes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,)
    x.config = config
    x.creator = creator
    x.id = id
    x.name = name
    x.infectiousAgent = infectiousAgent
    x.contactExposures = contactExposures
    x.outbreakInfectiousStatusAssoes = outbreakInfectiousStatusAssoes
    return x
  end

end 