mux_filters = ()
include("mux_get_appuser_from_jwt.jl")

mux_filters = (
    mux_filters...,
    Mux.stack(WebAPI.mux_get_appuser_from_jwt)
)

# include("check-jwt.jl")
