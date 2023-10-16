"""
    InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses(
        patient::Patient,
        forAnalysesBetween::Tuple{Date,Date},
        dbconn::LibPQ.Connection
    )

Generate carrier statuses from analyses

```
# Case without any external or manual creation of infectious status:

External or manual input:

Analyses:                 pos     neg     neg
                           ▼               ▼
Infectious status:        car             nar
_______________________________________________________________________________

# Case with an external or manual creation of infectious status:

External or manual input:                   car
                                             │
Analyses:                  neg     neg       │    pos        neg        neg
                            ▼                ▼                           ▼
Infectious status:         nar              car                         nar
```
"""
function generateCarrierStatusesFromAnalyses end

function generateNotAtRiskStatusesFromAnalyses end

function generateNotAtRiskStatusForDeadPatient end

function generateContactStatusFromExposure end

function getInfectiousStatusForListing end

function getInfectiousStatuses end

function getInfectiousStatusesAtTime end

function getInfectiousStatusAtTime end

function checkIfPatientIsCarrierAtTime end

"""
An infectious status for a given infectious agent is tagged current status if
it is the last or the last confirmed.

This means we can be in the following scenario:
    - Infectious status for carba bacteria,
        Ref time = 2022-03-22 13:00:00, status = carrier, isConfirmed = true, isCurrent = true
    - Infectious status for carba bacteria,
        Ref time 2022-03-28 13:00:00, status = not_at_risk, isConfirmed = false, isCurrent = true
"""
function updateCurrentStatus end

function defaultCheckIfNotAtRiskAnymore end

function upsert! end

function updateOutbreakInfectiousStatusAssos end

function delete end
