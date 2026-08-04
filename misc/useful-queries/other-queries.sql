-- The Maximum in date of the database
select stay.id, max(stay.in_date) 
from stay 
WHERE stay.in_date > '2021-12-01' 
group by stay.id 
ORDER BY max(stay.in_date) dESC

-- Some patients name
SELECT pgp_sym_decrypt(pnc.lastname_crypt, '6c65737369766520626174746572696520636861746f6e20636f746f6e20646f72746f6972') as lastname,
        s.*
FROM stay s
INNER JOIN patient p
  ON p.id  = s.patient_id
INNER JOIN patient_name_crypt pnc
  ON  p.name_crypt_id = pnc.id
WHERE s.in_date >= '2021-12-10'