function OutbreakUnitAssoCtrl.refreshOutbreakUnitAssos(
    outbreak::Outbreak,
    dbconn::LibPQ.Connection
)::Vector{OutbreakUnitAsso}


    # Get the confirmed carriers infectious statuses of the outbreak
    queryString = "
    SELECT ist.*
    FROM outbreak
    JOIN outbreak_infectious_status_asso oisa
      ON  oisa.outbreak_id = outbreak.id
    JOIN infectious_status ist
      ON ist.id = oisa.infectious_status_id
    WHERE outbreak.id = \$1
      AND ist.infectious_status = 'carrier'
      AND ist.is_confirmed = 'true'
    "
    confirmedCarrierInfectiousStatuses = PostgresORM.execute_query_and_handle_result(
        queryString, InfectiousStatus, [outbreak.id], false, dbconn
    )

    # Get all the carrier stays at risk of the outbreak
    atRiskStays = Stay[]
    for carrierStatus in confirmedCarrierInfectiousStatuses
        push!(
            atRiskStays,
            StayCtrl.getStaysWherePatientAtRisk(carrierStatus, dbconn)...
            )
        end

    # Build a dataframe of the carrier stays
    atRiskStaysDf = [
            (
                unitId = s.unit.id,
                inTime = s.inTime,
                outTime = s.outTime
            ) for s in atRiskStays
        ] |>
        n -> DataFrame(n)


    # Group by unit.id and compute min(inTime) and max(outTime)
    minMaxPerUnitDf = combine(
        DataFrames.groupby(atRiskStaysDf, :unitId),
        :inTime => minimum => :minInTime,
        :outTime => maximum => :maxOutTime
    )

    # Upsert the assos
    refreshedAssos = OutbreakUnitAsso[]
    for r in eachrow(minMaxPerUnitDf)
        asso = OutbreakUnitAsso(
            outbreak = outbreak,
            unit = Unit(id = r.unitId),
            startTime = r.minInTime,
            endTime = r.maxOutTime
        )
        OutbreakUnitAssoCtrl.upsert!(asso, dbconn)
        push!(
            refreshedAssos,
            asso
        )
    end

    newIds = getproperty.(refreshedAssos,:id)

    oldAssos::Vector{OutbreakUnitAsso} = PostgresORM.retrieve_entity(
        OutbreakUnitAsso(outbreak = outbreak),
        false,
        dbconn
    )

    # Delete the assos that are deprecated
    for oldAsso in oldAssos
        if oldAsso.id ∉ newIds
            PostgresORM.delete_entity(oldAsso, dbconn)
        end
    end

    return refreshedAssos

end
