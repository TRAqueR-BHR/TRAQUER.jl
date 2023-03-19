select at.code_name,a.result_value from analysis a
INNER JOIN analysis_type at
  ON a.analysis_type_id = at.id

-- Analysis and corresponding stays
SELECT a.*
       ,pgp_sym_decrypt(arc.ref_crypt, 'aaaaaaaxxxxxcccccc') AS analysis_ref
       ,pgp_sym_decrypt(pbc.birthdate_crypt, 'aaaaaaaxxxxxcccccc') AS birthdate
       ,pgp_sym_decrypt(pnc.firstname_crypt, 'aaaaaaaxxxxxcccccc') AS firstname
       ,pgp_sym_decrypt(pnc.lastname_crypt, 'aaaaaaaxxxxxcccccc') AS lastname
FROM analysis_result a
LEFT JOIN stay s
  ON a.stay_id = s.id
INNER JOIN patient p
  ON p.id  = a.patient_id
INNER JOIN analysis_ref_crypt arc
  ON a.ref_one_char = arc.one_char
  AND a.ref_crypt_id = arc.id
JOIN patient_birthdate_crypt pbc
    ON  pbc.year = p.birth_year
    AND pbc.id = p.birthdate_crypt_id
JOIN patient_name_crypt pnc
    ON  pnc.lastname_first_letter = p.lastname_first_letter
    AND pnc.id = p.name_crypt_id


-- Stays only
SELECT pgp_sym_decrypt(pnc.lastname_crypt, 'aaaaaaaxxxxxcccccc') as lastname,
        s.*
FROM stay s
INNER JOIN patient p
  ON p.id  = s.patient_id
INNER JOIN patient_name_crypt pnc
  ON  p.name_crypt_id = pnc.id
WHERE s.in_date >= '2021-12-10'

-- Patients names
SELECT p.id,pgp_sym_decrypt(pnc.lastname_crypt, 'aaaaaaaxxxxxcccccc') as lastname
FROM patient p
INNER JOIN patient_name_crypt pnc
  ON  p.name_crypt_id = pnc.id
