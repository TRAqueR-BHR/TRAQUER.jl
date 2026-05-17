function Conf.getNumberOfNegativeTestsForContactExclusion()
    parse(Int, Conf.getConf("rules_parameters","number_of_negative_tests_for_contact_exclusion"))
end
