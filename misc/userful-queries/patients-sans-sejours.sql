with patient_without_stay as (
	select analysis_result.patient_id
	from analysis_result
	where analysis_result.patient_id not in (
		select patient_id from stay
	) LIMIT 4
)

SELECT a.*
        ,p.id AS patient_id
        ,pgp_sym_decrypt(pbc.birthdate_crypt, 'aaaaaaaxxxxxcccccc') AS birthdate
        ,pgp_sym_decrypt(pnc.firstname_crypt, 'aaaaaaaxxxxxcccccc') AS firstname
        ,pgp_sym_decrypt(pnc.lastname_crypt, 'aaaaaaaxxxxxcccccc') AS lastname
FROM analysis_result a
JOIN patient p
    ON a.patient_id = p.id
JOIN patient_birthdate_crypt pbc
    ON  pbc.year = p.birth_year
    AND pbc.id = p.birthdate_crypt_id
JOIN patient_name_crypt pnc
    ON  pnc.lastname_first_letter = p.lastname_first_letter
    AND pnc.id = p.name_crypt_id
WHERE p.id in (select patient_id from patient_without_stay)
