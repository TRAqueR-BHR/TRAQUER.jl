include("../runtests-prerequisite.jl")

@testset "Test ContactExposureCtrl.generateContactExposures" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

        ContactExposureCtrl.generateContactExposures(Date("2020-01-01"), dbconn)

    end

end


@testset "Test ContactExposureCtrl.generateContactExposures" begin
    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

        infectiousStatus = PostgresORM.retrieve_one_entity(
            InfectiousStatus(id = "377177cf-67d7-44a8-8540-c2aa7b012a7d"),
            false,
            dbconn)

        contactStays = ContactExposureCtrl.generateContactExposures(
            infectiousStatus, dbconn)

    end
end

@testset "Test ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

        outbreakUnitAsso = PostgresORM.retrieve_one_entity(
            OutbreakUnitAsso(id = "d5586b49-c77c-4b24-9fda-dc9246e66738"),
            true, # complex props
            dbconn)

        ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(
            outbreakUnitAsso, dbconn
        )

    end

end
