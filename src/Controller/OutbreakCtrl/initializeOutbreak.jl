function OutbreakCtrl.initializeOutbreak(
    outbreakName::String,
    firstInfectiousStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)

    outbreakConfig = OutbreakConfig(
        id = string(UUIDs.uuid4())) |> # PostgresORM 0.5.3 does not support objects without properties
        n ->  PostgresORM.create_entity!(n, dbconn)

    outbreak = Outbreak(
        name = outbreakName,
        infectiousAgent = firstInfectiousStatus.infectiousAgent,
        config = outbreakConfig) |> n ->  PostgresORM.create_entity!(n, dbconn)

    outbreakInfectiousStatusAsso = OutbreakInfectiousStatusAsso(
        outbreak = outbreak,
        infectiousStatus = firstInfectiousStatus) |> n -> PostgresORM.create_entity!(n, dbconn)


    # Generate the default associations between the outbreak and the units
    outbreakConfigUnitAssos = TRAQUERUtil.createDBConnAndExecute() do dbconn

        OutbreakConfigCtrl.generateDefaultOutbreakConfigUnitAssos(
            outbreak,
            false, # simulate::Bool,
            dbconn
        )

    end

    return outbreak


end
