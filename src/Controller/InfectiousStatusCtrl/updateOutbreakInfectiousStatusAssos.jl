function InfectiousStatusCtrl.updateOutbreakInfectiousStatusAssos(
    infectiousStatus::InfectiousStatus, dbconn::LibPQ.Connection
)

    # Update the infectious status
    PostgresORM.update_vector_property!(
        infectiousStatus, :outbreakInfectiousStatusAssoes, dbconn
    )

    # Refresh the outbreaks associated with the infectious status
    outbreaks = getproperty.(infectiousStatus.outbreakInfectiousStatusAssoes, :outbreak)
    for outbreak in outbreaks
        OutbreakCtrl.generateDefaultOutbreakUnitAssos(
            outbreak,
            false, # simulate::Bool,
            dbconn
        )
    end

end
