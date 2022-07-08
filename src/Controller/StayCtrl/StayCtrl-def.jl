function createStayIfNotExists end
function retrieveOneStay end

"""
    createStay(
        patient::Patient,
        unit::Unit,
        inTime::ZonedDateTime,
        outTime::Union{Missing,ZonedDateTime},
        hospitalizationInTime::Union{Missing,ZonedDateTime},
        hospitalizationOutTime::Union{Missing,ZonedDateTime},
        room::Union{Missing,String},
        dbconn::LibPQ.Connection
    )

Create a stay for a patient and update the current hospitalization status of the patient
"""
function createStay end

function retrieveOneStayContainingDateTime end

function updateCurrentHospitalizationStatus end

function getSortedPatientStays end
