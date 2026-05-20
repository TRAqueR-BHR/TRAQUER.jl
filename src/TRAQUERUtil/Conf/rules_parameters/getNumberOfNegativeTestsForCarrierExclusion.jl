function Conf.getNumberOfNegativeTestsForCarrierExclusion()
    parse(Int, Conf.getConf("rules_parameters","number_of_negative_tests_for_carrier_exclusion"))
end
