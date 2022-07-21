select at.code_name,a.result_value from analysis a
INNER JOIN analysis_type at
  ON a.analysis_type_id = at.id



-- Analysis and corresponding stays
SELECT pgp_sym_decrypt(pnc.lastname_crypt, 'aaaaaaaxxxxxcccccc') as lastname,
        pgp_sym_decrypt(arc.ref_crypt, 'aaaaaaaxxxxxcccccc') AS analysis_ref,
        a.*
FROM analysis a
INNER JOIN analysis_type t
  ON a.analysis_type_id = t.id
INNER JOIN analysis_ref_crypt arc
  ON a.ref_crypt_id = arc.id
INNER JOIN patient p
  ON p.id  = a.patient_id
INNER JOIN patient_name_crypt pnc
  ON  p.name_crypt_id = pnc.id
INNER JOIN stay s
  on a.stay_id = s.id
WHERE a.analysis_type_id = '52199d02-3242-4bf3-a61d-da9dcd19643c'


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