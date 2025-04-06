SELECT a.id
       ,pgp_sym_decrypt(arc.ref_crypt, 'xxxxxxx') AS analysis_ref
       ,pgp_sym_decrypt(pbc.birthdate_crypt, 'xxxxxxx') AS birthdate
       ,pgp_sym_decrypt(pnc.firstname_crypt, 'xxxxxxx') AS firstname
       ,pgp_sym_decrypt(pnc.lastname_crypt, 'xxxxxxx') AS lastname
FROM analysis_result a
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
WHERE a.request_type = 'bacterial_culture_carbapenemase_producing_enterobacteriaceae'
  AND a.result = 'positive'
  AND pgp_sym_decrypt(arc.ref_crypt, 'xxxxxxx') ilike '%_PREPC'
