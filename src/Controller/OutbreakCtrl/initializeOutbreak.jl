"""
    OutbreakCtrl.initializeOutbreak(
        outbreakName::AbstractString,
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
    outbreakName::AbstractString,
    firstInfectiousStatus::InfectiousStatus,
    criticity::OUTBREAK_CRITICITY,
    refTime::ZonedDateTime,
    dbconn::LibPQ.Connection
)

    try
        # Create the outbreak
        outbreak = Outbreak(
            name = outbreakName,
            infectiousAgent = firstInfectiousStatus.infectiousAgent,
            refTime = refTime,
            criticity = criticity) |>
            n ->  PostgresORM.create_entity!(n, dbconn)

        # Initialize the outbreak using the association with the carrier infectious status.
        # The infectious status may already be associated to an outbreak, in which case we
        # want to keep the existing association
        existingAssos = PostgresORM.retrieve_entity(
            OutbreakInfectiousStatusAsso(infectiousStatus = firstInfectiousStatus),
            false,
            dbconn
        )
        firstInfectiousStatus.outbreakInfectiousStatusAssoes = [
            existingAssos...,
            OutbreakInfectiousStatusAsso(outbreak = outbreak)
        ]
        InfectiousStatusCtrl.updateOutbreakInfectiousStatusAssos(
            firstInfectiousStatus, dbconn
        )

        return outbreak

    catch e

        # If unique constraint violation, throw custom error so that we can warn the user
        # in a friendly way
        if e isa LibPQ.Errors.UniqueViolation
            throw(OutbreakNameAlreadyUsedError("$outbreakName $(getTranslation("is_already_used") |> lowercase)"))
        else
            rethrow()
        end
    end

end
