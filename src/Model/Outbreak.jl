mutable struct Outbreak <: IOutbreak 

  id::Union{Missing,String}
  name::Union{Missing,String}
  startDate::Union{Missing,Date}
  endDate::Union{Missing,Date}
  outbreakInfectiousStatusAssoes::Union{Missing,Vector{Model.IOutbreakInfectiousStatusAsso}}

  Outbreak(args::NamedTuple) = Outbreak(;args...)
  Outbreak(;
    id = missing,
    name = missing,
    startDate = missing,
    endDate = missing,
    outbreakInfectiousStatusAssoes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,)
    x.id = id
    x.name = name
    x.startDate = startDate
    x.endDate = endDate
    x.outbreakInfectiousStatusAssoes = outbreakInfectiousStatusAssoes
    return x
  end

end 