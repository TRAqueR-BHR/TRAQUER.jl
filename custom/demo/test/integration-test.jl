include("../../../test/runtests-prerequisite.jl")

# Cleaning
MaintenanceCtrl.resetDatabase()

# ETL
include("runtests-demo-importStays.jl")
include("runtests-demo-importAnalyses.jl")

# Select all patients
patients = TRAQUERUtil.createDBConnAndExecute() do dbconn
    "SELECT p.*
    FROM patient p" |>
    n -> PostgresORM.execute_query_and_handle_result(n,Patient,missing,false,dbconn)
end


# Generate the carrier statuses from the analyses
TRAQUERUtil.createDBConnAndExecute() do dbconn

    for patient in patients

        InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses(
            patient,
            (Date("2020-01-01"), today()), # forAnalysesRequestsBetween::Tuple{Date,Date},
            dbconn
        )

    end

end

# Confirm carrier status of patient2 and generate an outbreak for it
outbreakPatient2 = TRAQUERUtil.createDBConnAndExecute() do dbconn

    patient2CarrierStatus = "
        SELECT ist.*
        FROM infectious_status ist
        JOIN patient p
          ON ist.patient_id = p.id
        JOIN patient_ref_crypt prc
          ON p.ref_one_char = prc.one_char
         AND p.ref_crypt_id = prc.id
        WHERE pgp_sym_decrypt(prc.ref_crypt, \$1) = \$2" |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            InfectiousStatus,
            [getDefaultEncryptionStr(),"patient2"],
            false,
            dbconn) |> first

    patient2CarrierStatus.isConfirmed = true
    PostgresORM.update_entity!(patient2CarrierStatus,dbconn)


    outbreakPatient2 = OutbreakCtrl.initializeOutbreak(
        "outbreak patient2", # outbreakName::AbstractString,
        patient2CarrierStatus, # firstInfectiousStatus::InfectiousStatus,
        OutbreakCriticity.EPIDEMIC,
        now(TRAQUERUtil.getTimeZone()),
        dbconn
    )
    return outbreakPatient2

end

# Generate the exposures for the outbreak of patient2
exposures = TRAQUERUtil.createDBConnAndExecute() do dbconn
    ContactExposureCtrl.generateContactExposures(
        outbreakPatient2,
        dbconn
    )
end



# Generate the not_at_risk infectious statuses from the analyses
TRAQUERUtil.createDBConnAndExecute() do dbconn

    for patient in patients

        InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
            patient,
            (Date("2020-01-01"), today()), # forAnalysesRequestsBetween::Tuple{Date,Date},
            dbconn
        )

    end

end
