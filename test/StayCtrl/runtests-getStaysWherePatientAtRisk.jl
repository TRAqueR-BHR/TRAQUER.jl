include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getStaysWherePatientAtRisk" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        infectiousStatus = PostgresORM.retrieve_one_entity(
            InfectiousStatus(id = "9af0ef4d-0b55-480a-b6ca-f56e8f7c2700"),
            false,
            dbconn
        )
        StayCtrl.getStaysWherePatientAtRisk(
            infectiousStatus,
            dbconn
        )
    end |>
    stays -> begin
        for s in stays
            @info "$(s.unit.name): $(s.inTime) ➡ $(s.outTime) $(s.unit.canBeAssociatedToAnOutbreak)"
        end
    end

end
