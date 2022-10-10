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

@testset "Test ContactExposureCtrl.generateContactExposures" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

        outbreakConfigUnitAsso = PostgresORM.retrieve_one_entity(
            OutbreakConfigUnitAsso(id = "5bbf4755-84b1-4be4-950d-6903573d96e4"),
            true, # complex props
            dbconn)

        contactExposures = ContactExposureCtrl.generateContactExposures(
            outbreakConfigUnitAsso, dbconn
            ;simulate = true
        )

        for e in contactExposures
            patientDecrypt = PatientCtrl.getPatientDecrypt(
                e.contact,
                getDefaultEncryptionStr(),
                dbconn
                )
            @info "e.contact.id[$(e.contact.id)] patientDecrypt.lastname[$(patientDecrypt.lastname)]"
        end

    end

end
