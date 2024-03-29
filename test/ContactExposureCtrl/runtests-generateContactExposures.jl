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

        outbreakUnitAsso = PostgresORM.retrieve_one_entity(
            OutbreakUnitAsso(id = "2a211a7e-5965-4a1f-b9bd-49d393bba0d0"),
            true, # complex props
            dbconn)

        contactExposures = ContactExposureCtrl.generateContactExposures(
            outbreakUnitAsso,
            dbconn
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
