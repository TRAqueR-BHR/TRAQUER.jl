function Conf.getCarrierWaitingPeriod()
    parse(Int,Conf.getConf("rules_parameters","carrier_waiting_period_in_months")) |>
    Month
end
