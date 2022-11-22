"""
    OutbreakCtrl.initializeOutbreak(
        outbreakName::String,
        firstInfectiousStatus::InfectiousStatus,
        criticity::OUTBREAK_CRITICITY,
        refTime::ZonedDateTime,
        dbconn::LibPQ.Connection
    )

Initialize an outbreak and its associations. Note: `refTime` is passed as an argument (not
derived from firstInfectiousStatus.refTime) because an infectious status can preexist an
outbreak by several months, eg. when a carrier comes back to the hospital, the new outbreak
corresponding to this new hospitalization should have a reference time that is the date of
the new hospitalization
"""
function OutbreakCtrl.initializeOutbreak(
    outbreakName::String,
    firstInfectiousStatus::InfectiousStatus,
    criticity::OUTBREAK_CRITICITY,
    refTime::ZonedDateTime,
    dbconn::LibPQ.Connection
)

    outbreak = Outbreak(
        name = outbreakName,
        infectiousAgent = firstInfectiousStatus.infectiousAgent,
        refTime = refTime,
        criticity = criticity) |>
        n ->  PostgresORM.create_entity!(n, dbconn)

    outbreakInfectiousStatusAsso = OutbreakInfectiousStatusAsso(
        outbreak = outbreak,
        infectiousStatus = firstInfectiousStatus) |> n -> PostgresORM.create_entity!(n, dbconn)


    # Generate the default associations between the outbreak and the units
    outbreakUnitAssos = TRAQUERUtil.createDBConnAndExecute() do dbconn

        OutbreakCtrl.generateDefaultOutbreakUnitAssos(
            outbreak,
            false, # simulate::Bool,
            dbconn
        )

    end

    return outbreak


end
