select 'patient' as name,count(*) from patient
UNION ALL
select 'patient_birthdate_crypt',count(*) from patient_birthdate_crypt
UNION ALL
select 'patient_name_crypt',count(*) from patient_name_crypt
UNION ALL
select 'patient_ref_crypt',count(*) from patient_ref_crypt
UNION ALL
select 'stay',count(*) from stay
UNION ALL
select 'analysis_result', count(*) from analysis_result
UNION ALL
select 'analysis_ref_crypt',count(*) from analysis_ref_crypt

ORDER BY name
