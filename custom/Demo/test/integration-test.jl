include("../../../test/runtests-prerequisite.jl")

# Cleaning
TRAQUERUtil.createDBConnAndExecute() do dbconn

    "DELETE FROM stay" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM analysis_result" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM infectious_status" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM outbreak" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM contact_exposure" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

end

# ETL
include("runtests-Demo-importStays.jl")
include("runtests-Demo-importAnalyses.jl")

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

    outbreakPatient2Config =
        OutbreakConfig(
            id = "520ab98c-e7e1-4289-ab69-21b2f7c2a605",
            sameRoomOnly = false
        ) |>
        n -> if ismissing(PostgresORM.retrieve_one_entity(n,false,dbconn))
                PostgresORM.create_entity!(n, dbconn)
                return n
            else
                return n
            end

    outbreakPatient2 =
        Outbreak(name = "outbreak patient2") |>
        n -> if ismissing(PostgresORM.retrieve_one_entity(n, false, dbconn))
                n.infectiousAgent = patient2CarrierStatus.infectiousAgent
                n.config = outbreakPatient2Config
                PostgresORM.create_entity!(n, dbconn)
                return n
            else
                existingOutbreak = PostgresORM.retrieve_one_entity(n, false, dbconn)
                existingOutbreak.infectiousAgent = existingOutbreak.infectiousAgent
                existingOutbreak.config = outbreakPatient2Config
                PostgresORM.update_entity!(existingOutbreak, dbconn)
                return existingOutbreak
            end

    outbreakInfectiousStatusAsso = OutbreakInfectiousStatusAsso(
        outbreak = outbreakPatient2,
        infectiousStatus = patient2CarrierStatus
    )

    PostgresORM.retrieve_one_entity(outbreakInfectiousStatusAsso, false, dbconn) |>
    n -> if ismissing(n)
            PostgresORM.create_entity!(outbreakInfectiousStatusAsso, dbconn)
        end

    return outbreakPatient2

end

# Generate the exposures for the outbreak of patient2
exposures = TRAQUERUtil.createDBConnAndExecute() do dbconn
    ContactExposureCtrl.generateContactExposures(
        outbreakPatient2,
        dbconn
    )
end

# Generate the contact infectious statuses from the exposures
TRAQUERUtil.createDBConnAndExecute() do dbconn

    for patient in patients

        InfectiousStatusCtrl.generateContactStatusesFromContactExposures(
            patient,
            (Date("2020-01-01"), today()), # forAnalysesRequestsBetween::Tuple{Date,Date},
            dbconn
        )

    end

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
