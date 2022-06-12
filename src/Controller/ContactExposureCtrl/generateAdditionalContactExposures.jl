function ContactExposureCtrl.generateAdditionalContactExposures(
    outbreak::Outbreak, dbconn::LibPQ.Connection
)

    # Get the OutbreakConfigUnitAssos
    outbreakConfigUnitAssos = "SELECT ocua.*
        FROM outbreak o
        JOIN outbreak_config oc
        ON o.config_id = oc.id
        JOIN outbreak_config_unit_asso ocua
        ON ocua.outbreak_config_id = oc.id
        JOIN unit
        ON ocua.unit_id = unit.id
        WHERE
        o.id = \$1
        " |> n -> PostgresORM.execute_query_and_handle_result(
                n,
                OutbreakConfigUnitAsso,
                [outbreak.id],
                false,
                dbconn
            )

    exposures = ContactExposure[]
    for asso in outbreakConfigUnitAssos
        push!(
            exposures,
            ContactExposureCtrl.generateAdditionalContactExposures(
                outbreak,
                asso.unit,
                asso.startTime,
                asso.endTime,
                dbconn
            )
        )
    end

    return exposures

end

"""
"""
function ContactExposureCtrl.generateAdditionalContactExposures(
    outbreak::Outbreak,
    unit::Unit,
    startTime::ZonedDateTime,
    endTime::ZonedDateTime,
    dbconn::LibPQ.Connection
)

    return ContactExposureCtrl.generateContactExposures(
        outbreak,
        unit,
        startTime,
        endTime,
        missing, # room
        false, # sameRoomOnly::Bool,
        dbconn
    )

end
