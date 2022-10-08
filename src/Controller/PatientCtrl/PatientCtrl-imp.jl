include("getPatientDecrypt.jl")

function PatientCtrl.createPatientIfNoExist(firstname::String,
                                            lastname::String,
                                            birthdate::Date,
                                            ref::String,
                                            encryptionStr::String,
                                            dbconn::LibPQ.Connection)

    # Look for the patient
    patient::Union{Missing,Patient} =
        PatientCtrl.retrieveOnePatient(ref,
                                       encryptionStr,
                                       dbconn)

    # Create patient if missing
    if ismissing(patient)
        patient = PatientCtrl.createPatient(firstname,
                                           lastname,
                                           birthdate,
                                           ref,
                                           encryptionStr,
                                           dbconn)
    end

    return patient

end

function PatientCtrl.createPatient(firstname::String,
                                   lastname::String,
                                   birthdate::Date,
                                   ref::String,
                                   encryptionStr::String,
                                   dbconn::LibPQ.Connection)

    cryptedPatientName = PatientCtrl.createCryptedPatientName(firstname,
                                                              lastname,
                                                              encryptionStr,
                                                              dbconn)

    cryptedPatientBirthdate = PatientCtrl.createCryptedPatientBirthdate(birthdate,
                                                                        encryptionStr,
                                                                        dbconn)

    cryptedPatientRef = PatientCtrl.createCryptedPatientRef(ref,
                                                            encryptionStr,
                                                            dbconn)

    # Generate a patient reference used that can be shared between users with the
    #   dataset password and the administrators
    # patientRef = TRAQUERUtil.generateHumanReadableUniqueRef(patient)

    patient = Patient(patientNameCrypt = cryptedPatientName,
                      patientBirthdateCrypt = cryptedPatientBirthdate,
                      patientRefCrypt = cryptedPatientRef)

    PostgresORM.create_entity!(patient,dbconn)
    return patient
end

function PatientCtrl.createCryptedPatientName(firstname::String,
                                              lastname::String,
                                              encryptionStr::String,
                                              dbconn::LibPQ.Connection)

      # Create partition if needed
      TRAQUERUtil.createPartitionPatientNameIfNotExist(lastname,
                                                       dbconn)

      # The value used for comparion
      # Eg, "François Abélard" -> "abelard francois"
      firstname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(firstname)
      lastname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(lastname)
      lastnameFirstLetter = lastname_forCp[1]

      insertQueryStr =
          "INSERT INTO public.patient_name_crypt(lastname_first_letter,
                                                 lastname_crypt,
                                                 lastname_for_cp_crypt,
                                                 firstname_crypt,
                                                 firstname_for_cp_crypt)
           VALUES (\$2, -- lastname_first_letter
                   pgp_sym_encrypt(\$3,\$1), -- lastname_crypt
                   pgp_sym_encrypt(\$4,\$1), -- lastname_for_cp_crypt
                   pgp_sym_encrypt(\$5,\$1), -- firstname_crypt
                   pgp_sym_encrypt(\$6,\$1)  -- firstname_for_cp_crypt
                   )
           RETURNING *"
      insertQueryArgs = [encryptionStr,
                         lastnameFirstLetter,
                         lastname,
                         lastname_forCp,
                         firstname,
                         firstname_forCp,
                         ]

      patientNameCrypt =
          PostgresORM.execute_query_and_handle_result(insertQueryStr,
                                                      PatientNameCrypt,
                                                      insertQueryArgs,
                                                      false,
                                                      dbconn)
      return first(patientNameCrypt)

end

function PatientCtrl.createCryptedPatientBirthdate(birthdate::Date,
                                                   encryptionStr::String,
                                                   dbconn::LibPQ.Connection)

    # Create partition if needed
    TRAQUERUtil.createPartitionPatientBirthdateIfNotExist(birthdate,
                                                          dbconn)

    birthdateAsStr = string(birthdate)
    year = Dates.year(birthdate)

    insertQueryStr =
        "INSERT INTO public.patient_birthdate_crypt(year,
                                               birthdate_crypt)
         VALUES (\$2, -- year
                 pgp_sym_encrypt(\$3,\$1) -- birthdate_crypt
                 )
         RETURNING *"
    insertQueryArgs = [encryptionStr,
                       year,
                       birthdateAsStr]
    patientNameCrypt =
        PostgresORM.execute_query_and_handle_result(insertQueryStr,
                                                    PatientBirthdateCrypt,
                                                    insertQueryArgs,
                                                    false,
                                                    dbconn)
    return first(patientNameCrypt)
end

function PatientCtrl.createCryptedPatientRef(ref::String,
                                             encryptionStr::String,
                                             dbconn::LibPQ.Connection)

       # Create partition if needed
       TRAQUERUtil.createPartitionPatientRefIfNotExist(ref,
                                                       dbconn)

      refOneChar = PatientCtrl.getRefOneChar(ref)

      insertQueryStr =
          "INSERT INTO public.patient_ref_crypt(one_char,
                                                ref_crypt)
           VALUES (\$2, -- one_char
                   pgp_sym_encrypt(\$3,\$1) -- ref_crypt
                   )
           RETURNING *"
      insertQueryArgs = [encryptionStr,
                         refOneChar,
                         ref]
      patientRefCrypt =
          PostgresORM.execute_query_and_handle_result(insertQueryStr,
                                                      PatientRefCrypt,
                                                      insertQueryArgs,
                                                      false,
                                                      dbconn)
      return first(patientRefCrypt)

end

function PatientCtrl.retrieveOnePatient(ref::String,
                                        encryptionStr::String,
                                        dbconn::LibPQ.Connection)

    patients = PatientCtrl.retrievePatientsFromRef(ref,
                                        encryptionStr,
                                        dbconn)
    if isempty(patients)
        return missing
    else
        first(patients)
    end
end

function PatientCtrl.retrieveOnePatient(firstname::String,
                                     lastname::String,
                                     birthdate::Date,
                                     encryptionStr::String,
                                     dbconn::LibPQ.Connection)

     patients = PatientCtrl.retrievePatients(firstname,
                                             lastname,
                                             birthdate,
                                             encryptionStr,
                                             dbconn)
     if isempty(patients)
         return missing
     else
         return first(patients)
     end

end

function PatientCtrl.retrievePatients(firstname::String,
                                     lastname::String,
                                     birthdate::Date,
                                     encryptionStr::String,
                                     dbconn::LibPQ.Connection)

     lastname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(lastname)
     firstname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(firstname)
     lastnameFirstLetter = lastname_forCp[1]
     _year = Dates.year(birthdate)
     queryString = "SELECT p.* FROM patient p
                    INNER JOIN public.patient_name_crypt pnc
                      ON (p.lastname_first_letter = pnc.lastname_first_letter
                        AND p.name_crypt_id = pnc.id)
                    INNER JOIN public.patient_birthdate_crypt pbc
                        ON (p.birth_year = pbc.year
                        AND p.birthdate_crypt_id = pbc.id)
                    WHERE p.lastname_first_letter = \$2
                      AND p.birth_year = \$3
                      AND pgp_sym_decrypt(pnc.lastname_for_cp_crypt, \$1) = \$4
                      AND pgp_sym_decrypt(pnc.firstname_for_cp_crypt, \$1) = \$5"

     queryArgs = [encryptionStr,
                  lastnameFirstLetter,
                  _year,
                  lastname_forCp,
                  firstname_forCp]
     patients = PostgresORM.execute_query_and_handle_result(
             queryString, Patient, queryArgs,
             false, # complex props
             dbconn)

     patients
end

function PatientCtrl.retrievePatientsFromLastname(lastname::String,
                                                  encryptionStr::String,
                                                  dbconn::LibPQ.Connection)

    lastname = string(lastname)
    lastname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(lastname)
    lastnameFirstLetter = lastname_forCp[1]
    queryString = "SELECT p.* FROM patient p
                   INNER JOIN public.patient_name_crypt pnc
                      ON (p.lastname_first_letter = pnc.lastname_first_letter
                        AND p.name_crypt_id = pnc.id)
                   WHERE pnc.lastname_first_letter = \$3
                     AND pgp_sym_decrypt(pnc.lastname_for_cp_crypt, \$1) = \$2"

    queryArgs = [encryptionStr,
                 lastname_forCp,
                 lastnameFirstLetter]
    patients = PostgresORM.execute_query_and_handle_result(
            queryString, Patient, queryArgs,
            false, # complex props
            dbconn)

    patients

end

function PatientCtrl.retrievePatientsFromBirthdate(birthdate::Date,
                                                   encryptionStr::String,
                                                   dbconn::LibPQ.Connection)

    birthdateAsStr = string(birthdate)
    _year = year(birthdate)
    queryString = "SELECT p.* FROM patient p
                   INNER JOIN public.patient_birthdate_crypt pbc
                        ON (p.birth_year = pbc.year
                        AND p.birthdate_crypt_id = pbc.id)
                   WHERE pbc.year = \$3
                     AND pgp_sym_decrypt(pbc.birthdate_crypt, \$1) = \$2
                   "
    queryArgs = [encryptionStr,
                 birthdateAsStr,
                 _year]
    patients = PostgresORM.execute_query_and_handle_result(
            queryString, Patient, queryArgs,
            false, # complex props
            dbconn)

    patients

end

function PatientCtrl.getRefOneChar(ref::String)
    refOneChar = lowercase(ref[1])
    return refOneChar
end

function PatientCtrl.retrievePatientsFromRef(ref::String,
                                             encryptionStr::String,
                                             dbconn::LibPQ.Connection)

    refOneChar = PatientCtrl.getRefOneChar(ref)
    queryString = "SELECT p.* FROM patient p
                   INNER JOIN public.patient_ref_crypt prc
                      ON (p.ref_one_char = prc.one_char
                        AND p.ref_crypt_id = prc.id)
                   WHERE prc.one_char = \$3
                     AND pgp_sym_decrypt(prc.ref_crypt, \$1) = \$2"

    queryArgs = [encryptionStr,
                 ref,
                 refOneChar]

    @info queryArgs
    patients = PostgresORM.execute_query_and_handle_result(
            queryString, Patient, queryArgs,
            false, # complex props
            dbconn)

    patients

end
