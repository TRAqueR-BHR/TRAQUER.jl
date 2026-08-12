function _TestUtils.buildRandomPatientBirthdate()
    # Generate a random patient birthdate
    start_date = today() - Year(110)
    end_date = today() - Year(1)
    random_days = rand(0:(end_date - start_date).value)
    birthdate = start_date + Day(random_days)
    return birthdate
end
