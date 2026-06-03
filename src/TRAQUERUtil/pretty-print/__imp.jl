include("formatStructForPrinting.jl")

PrettyPrint.pp_impl(io::IO, x::DateTime, indent::Int) = begin
    s = "$x"
    print(io, s)
    return length(s) + indent
end
