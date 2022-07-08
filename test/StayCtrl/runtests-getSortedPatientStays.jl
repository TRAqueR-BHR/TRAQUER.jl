include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getSortedPatientStays" begin

    nowMinus1 = ZonedDateTime(now(),getTimezone()) - Minute(1)
    nowMinus2 = ZonedDateTime(now(),getTimezone()) - Minute(2)
    nowMinus3 = ZonedDateTime(now(),getTimezone()) - Minute(3)

    stay1 = Stay(
        id = "stay1",
        inTime = nowMinus3,
        outTime = nowMinus2,
        hospitalizationInTime = nowMinus3,
        hospitalizationOutTime = missing,
        unit = Unit(name = "unit1")
        )
    stay2 = Stay(
        id = "stay2",
        inTime = nowMinus2,
        outTime = nowMinus1,
        hospitalizationInTime = nowMinus3,
        hospitalizationOutTime = missing,
        unit = Unit(name = "unit1")
        )

    stays = [
        stay2, stay1
    ]

    patch_execute_query_and_handle_result_for_Stay =
        @patch PostgresORM.execute_query_and_handle_result(
            n::String,
            _type::Type{Stay},
            queryArgs,
            complexProps::Bool,
            dbconn::LibPQ.Connection) = stays

    Mocking.activate()
    result = apply([patch_execute_query_and_handle_result_for_Stay]) do
        TRAQUERUtil.createDBConnAndExecute() do dbconn
            StayCtrl.getSortedPatientStays(
                Patient(),
                dbconn
            )
        end
    end
    Mocking.deactivate()

    last(result).id

end
