include("../runtests-prerequisite.jl")


@testset "Test ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses for one unit asso" begin

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


@testset "Test ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses for all outbreaks" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
        ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(dbconn)
    end

end
