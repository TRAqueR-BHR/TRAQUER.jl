"""
    ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(dbconn::LibPQ.Connection)

Generate the contact exposures and associated infectious statuses for all carriers or only
the ones that are hospitalized.
"""
function ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(dbconn::LibPQ.Connection)

    # Get the outbreaks of the carriers still hospitalized
    queryString = "
    SELECT oua.*
    FROM patient p
    JOIN infectious_status ist
        ON ist.patient_id = p.id
    JOIN outbreak_infectious_status_asso oista
        ON oista.infectious_status_id = ist.id
    JOIN outbreak o
        ON o.id = oista.outbreak_id
    JOIN outbreak_unit_asso oua
        ON oua.outbreak_id = o.id
    WHERE ist.infectious_status = 'carrier'
    "

    # When doing integration test we want to consider all carriers, including the ones out
    if !TRAQUERUtil.debugIncludeCarriersThatAreNotHospitalized()
        queryString *= "AND p.is_hospitalized = 't'"
    end

    outbreakUnitAssos = PostgresORM.execute_query_and_handle_result(
        queryString, OutbreakUnitAsso, missing, false, dbconn
    )

    for asso in outbreakUnitAssos
        ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(asso, dbconn)
    end

end

function ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(
    asso::OutbreakUnitAsso, dbconn::LibPQ.Connection
)

    PostgresORM.update_entity!(asso, dbconn)

    exposures::Vector{ContactExposure} = ContactExposureCtrl.generateContactExposures(asso, dbconn)

    for exposure in exposures
        InfectiousStatusCtrl.generateContactStatusFromExposure(exposure,dbconn)
    end

end
