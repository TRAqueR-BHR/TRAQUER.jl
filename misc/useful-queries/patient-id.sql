SELECT p.id AS patient_id
        ,pgp_sym_decrypt(pbc.birthdate_crypt, '6c65737369766520626174746572696520636861746f6e20636f746f6e20646f72746f6972') AS birthdate
        ,pgp_sym_decrypt(pnc.firstname_crypt, '6c65737369766520626174746572696520636861746f6e20636f746f6e20646f72746f6972') AS firstname
        ,pgp_sym_decrypt(pnc.lastname_crypt, '6c65737369766520626174746572696520636861746f6e20636f746f6e20646f72746f6972') AS lastname
FROM patient p
JOIN patient_birthdate_crypt pbc
    ON  pbc.year = p.birth_year
    AND pbc.id = p.birthdate_crypt_id
JOIN patient_name_crypt pnc
    ON  pnc.lastname_first_letter = p.lastname_first_letter
    AND pnc.id = p.name_crypt_id
JOIN patient_ref_crypt prc
    ON prc.one_char = p.ref_one_char
    AND prc.id = p.ref_crypt_id
WHERE pnc.lastname_first_letter = 'r'
	AND pgp_sym_decrypt(pnc.lastname_for_cp_crypt, '6c65737369766520626174746572696520636861746f6e20636f746f6e20646f72746f6972') = 'rosaine'
	AND pgp_sym_decrypt(pnc.firstname_for_cp_crypt, '6c65737369766520626174746572696520636861746f6e20636f746f6e20646f72746f6972') = 'michel'
