include("../runtests-prerequisite.jl")

@testset "Test InfectiousStatusCtrl.updateCurrentStatus" begin

    infectiousStatusesForTesting = [
        InfectiousStatus(
            id = "carba 1 => current = true",
            infectiousAgent = InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
            infectiousStatus = InfectiousStatusType.carrier,
            refTime = ZonedDateTime(DateTime("2022-03-22T11:00:00"),TRAQUERUtil.getTimeZone()),
            isConfirmed = false
        ),
        InfectiousStatus(
            id = "vanco 1 => current = true",
            infectiousAgent = InfectiousAgentCategory.vancomycin_resistant_enterococcus,
            infectiousStatus = InfectiousStatusType.contact,
            refTime = ZonedDateTime(DateTime("2022-03-22T10:00:00"),TRAQUERUtil.getTimeZone()),
            isConfirmed = true
        ),
        InfectiousStatus(
            id = "vanco 2 => current = false",
            infectiousAgent = InfectiousAgentCategory.vancomycin_resistant_enterococcus,
            infectiousStatus = InfectiousStatusType.contact,
            refTime = ZonedDateTime(DateTime("2022-03-22T08:00:00"),TRAQUERUtil.getTimeZone()),
            isConfirmed = false
        ),
        InfectiousStatus(
            id = "carba 2 confirmed with carba 1 unconfirmed => current = true",
            infectiousAgent = InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
            infectiousStatus = InfectiousStatusType.contact,
            refTime = ZonedDateTime(DateTime("2022-03-22T09:00:00"),TRAQUERUtil.getTimeZone()),
            isConfirmed = true,
        ),
        InfectiousStatus(
            id = "carba 3 => current = false",
            infectiousAgent = InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
            infectiousStatus = InfectiousStatusType.contact,
            refTime = ZonedDateTime(DateTime("2022-03-22T04:00:00"),TRAQUERUtil.getTimeZone()),
            isConfirmed = true,
        ),
    ]

    # Mocking patches
    patch_execute_query_and_handle_result = @patch PostgresORM.execute_query_and_handle_result(
        query_string,
        data_type,
        query_args,
        retrieve_complex_props,
        dbconn::LibPQ.Connection) = infectiousStatusesForTesting

    patch_update_entity! = @patch PostgresORM.update_entity!(
        updated_object, dbconn) = println("PostgresORM.update_entity! overwritten => Do nothing")

    Mocking.activate()  # Need to call `activate` before executing `apply`
    res = apply([patch_execute_query_and_handle_result,patch_update_entity!]) do
        TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
            InfectiousStatusCtrl.updateCurrentStatus(
                Patient(id = "d538eb57-8c22-47bf-a9da-10b75da7b295"),
                dbconn)
        end
    end
    Mocking.deactivate()  # Need to call `activate` before executing `apply`

    for infectiousStatus in res
        @info infectiousStatus.id infectiousStatus.isCurrent

        expected = infectiousStatus.id |>  n -> match(r"current = (true|false)",n) |>
        n -> n.captures[1] |> n -> parse(Bool,n)
        @test infectiousStatus.isCurrent === expected

    end

end
