
function PatientCtrl.getPatientDecryptedInfoFromId(
    patientId::String,
    encryptionStr::String,
    dbconn::LibPQ.Connection)

    patients = PatientCtrl.getPatientsDecryptedInfoFromIds(
        [patientId],
        encryptionStr,
        dbconn)
    if isempty(patients)
        return missing
    else
        first(patients)
    end

end

function PatientCtrl.getPatientsDecryptedInfoFromIds(
    patientIds::Vector{String},
    encryptionStr::String,
    dbconn::LibPQ.Connection)

    # ########################### #
    # Get the birth date and name #
    # ########################### #
    queryString = "
    SELECT DISTINCT
        p.id AS patient_id,
        pgp_sym_decrypt(pnc.firstname_crypt, \$1) AS firstname,
        pgp_sym_decrypt(pnc.lastname_crypt,  \$1) AS lastname,
        date(pgp_sym_decrypt(pbc.birthdate_crypt, \$1)) AS birthdate,
        pgp_sym_decrypt(prc.ref_crypt, \$1) AS ref
    FROM patient.patient p
    INNER JOIN patient.patient_name_crypt pnc
        ON (p.lastname_first_letter = pnc.lastname_first_letter
        AND p.name_crypt_id = pnc.id)
    INNER JOIN patient.patient_ref_crypt prc
        ON (p.ref_one_char = prc.one_char
        AND p.ref_crypt_id = prc.id)
    INNER JOIN patient.patient_birthdate_crypt pbc
        ON (p.birth_year = pbc.year
        AND p.birthdate_crypt_id = pbc.id)
    WHERE p.id = ANY(\$2)"

    queryArgs = [encryptionStr,
                 patientIds]
    patientNameAndBirthdate = PostgresORM.execute_plain_query(queryString, queryArgs,dbconn)

    # ########################################## #
    # Get other basic information from the exams #
    # ########################################## #
    queryString = "
    SELECT DISTINCT
        e.patient_id,
        e.id AS exam_id,
        v.name AS variable_name,
        pgp_sym_decrypt(vvc.value_crypt, \$1) AS value_decrypt
    FROM patient.patient p
    INNER JOIN exam e
        ON e.patient_id = p.id
    INNER JOIN variable_value vv
        ON  vv.year = e.year
        AND vv.exam_id = e.id
    INNER JOIN variable v
        ON vv.variable_id = v.id
    INNER JOIN variable_value_crypt vvc
        ON vvc.id = vv.crypt_id
    WHERE 1 = 1
        AND p.id = ANY(\$2)
        AND v.name = ANY(\$3)
    "

    variablesOI = ["gender","phone"]

    queryArgs = [encryptionStr,
                 patientIds,
                 variablesOI]
    queryRes = PostgresORM.execute_plain_query(queryString, queryArgs, dbconn)

    patientOtherBasicInfo = unstack(queryRes,:variable_name,:value_decrypt)

    # Add the columns for the variables of interest in case the result of the query had no
    #   value with this name
    for varOI in variablesOI
        if !hasproperty(patientOtherBasicInfo,varOI)
            patientOtherBasicInfo[:,varOI] = fill(missing,nrow(patientOtherBasicInfo))
        end
    end

    latestNonMissingRowAsDataFrame = if !isempty(patientOtherBasicInfo)
        patientOtherBasicInfo
    else
        patientOtherBasicInfo
    end

    resultAsDataFrame = leftjoin(patientNameAndBirthdate,latestNonMissingRowAsDataFrame
                    ;on = :patient_id)

    return resultAsDataFrame

end
