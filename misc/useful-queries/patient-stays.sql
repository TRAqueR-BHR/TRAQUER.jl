SELECT s.*
        ,pgp_sym_decrypt(pbc.birthdate_crypt, 'aaaaaaaxxxxxcccccc') AS birthdate
        ,pgp_sym_decrypt(pnc.firstname_crypt, 'aaaaaaaxxxxxcccccc') AS firstname
        ,pgp_sym_decrypt(pnc.lastname_crypt, 'aaaaaaaxxxxxcccccc') AS lastname
FROM stay s
JOIN patient p
    ON s.patient_id = p.id
JOIN patient_birthdate_crypt pbc
    ON  pbc.year = p.birth_year
    AND pbc.id = p.birthdate_crypt_id
JOIN patient_name_crypt pnc
    ON  pnc.lastname_first_letter = p.lastname_first_letter
    AND pnc.id = p.name_crypt_id
WHERE pgp_sym_decrypt(pnc.lastname_crypt, 'aaaaaaaxxxxxcccccc') = 'Etlesgarçons'
ORDER BY s.inTime
