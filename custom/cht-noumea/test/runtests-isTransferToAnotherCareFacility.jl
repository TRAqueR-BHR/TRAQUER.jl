include("prerequisite.jl")

@testset "Test Custom.isTransferToAnotherCareFacility" begin


    @test Custom.isTransferToAnotherCareFacility("Transfert djfi hdifhai") === true
    @test Custom.isTransferToAnotherCareFacility("transfert djfi hdifhai") === true
    @test Custom.isTransferToAnotherCareFacility(missing) === false
    @test Custom.isTransferToAnotherCareFacility("Placement Maison de Retraite") === true
    @test Custom.isTransferToAnotherCareFacility("Deces") === false
end
