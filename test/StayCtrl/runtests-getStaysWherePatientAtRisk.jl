include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getStaysWherePatientAtRisk" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        infectiousStatus = PostgresORM.retrieve_one_entity(
            InfectiousStatus(id = "d744f06f-7fb1-456a-b3b2-156bae5a908d"),
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
            @info "$(s.unit.name): $(s.inTime) ➡ $(s.outTime)"
        end
    end

end
