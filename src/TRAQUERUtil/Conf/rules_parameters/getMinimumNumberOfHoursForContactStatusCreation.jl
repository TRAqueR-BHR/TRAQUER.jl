function Conf.getMinimumNumberOfHoursForContactStatusCreation()
    parse(Int,Conf.getConf("rules_parameters","minimum_number_of_hours_for_contact_status_creation")) |>
    Hour
end
