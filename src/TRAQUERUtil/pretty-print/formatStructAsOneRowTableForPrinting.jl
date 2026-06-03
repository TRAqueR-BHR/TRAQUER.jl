# let
#     struct Person
#         name::String
#         age::Int
#     end

#     function pretty_struct_to_string(x)
#         io = IOBuffer()
#         fields = fieldnames(typeof(x))
#         vals = reshape(collect(getfield(x, f) for f in fields), 1, :)
#         header = string.(fields) |> collect
#         pretty_table(io, vals; header=header)
#         return String(take!(io))
#     end

#     p = Person("Alice", 30)

#     @info "Person info:\n$(pretty_struct_to_string(p))"
# end
