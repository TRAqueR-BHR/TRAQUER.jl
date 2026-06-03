include("__prerequisite.jl")

@testset "Test TRAQUERUtil.formatStructForPrinting" begin

    struct S1
        i :: Int
        f :: Float64
    end

    struct S2
        s  :: Vector{String}
        s1 :: S1
    end

    data = S2(
        ["114514", "as we can"],
        S1(42, 9.96)
    )

    TRAQUERUtil.formatStructForPrinting(data) |> n -> @info n

end
