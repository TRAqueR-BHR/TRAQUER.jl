function PatientCtrl.getPatientDecrypt(
    patient::Patient,
    encryptionStr::AbstractString,
    dbconn::LibPQ.Connection
    ;includePatientRef::Bool = false
)::Union{Missing,PatientDecrypt}


    selectPart = "
        SELECT p.id AS patient_id
        ,pgp_sym_decrypt(pbc.birthdate_crypt, \$1) AS birthdate
        ,pgp_sym_decrypt(pnc.firstname_crypt, \$1) AS firstname
        ,pgp_sym_decrypt(pnc.lastname_crypt, \$1) AS lastname
    "
    if includePatientRef
        selectPart *= ",pgp_sym_decrypt(prc.ref_crypt, \$1) AS patient_ref"
    end

    joinPart = "
        FROM patient p
        JOIN patient_birthdate_crypt pbc
          ON  pbc.year = p.birth_year
          AND pbc.id = p.birthdate_crypt_id
        JOIN patient_name_crypt pnc
          ON  pnc.lastname_first_letter = p.lastname_first_letter
          AND pnc.id = p.name_crypt_id
    "
    if includePatientRef
        joinPart *= "
            JOIN patient_ref_crypt prc
                ON (
                    p.ref_one_char = prc.one_char
                    AND p.ref_crypt_id = prc.id
                )
        "
    end

    wherePart = "WHERE p.id = \$2"

    queryString = """
        $selectPart
        $joinPart
        $wherePart
    """

    @info queryString

    patientDecryptData = queryString |>
            n -> PostgresORM.execute_query_and_handle_result(
                n,
                PatientDecrypt,
                [encryptionStr, patient.id],
                false,
                dbconn
            ) |>
            n -> if isempty(n) missing else first(n) end

    return patientDecryptData

end
