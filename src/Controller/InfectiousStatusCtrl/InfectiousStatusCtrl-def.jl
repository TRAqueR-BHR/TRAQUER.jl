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
Infectious status:        car             nor
_______________________________________________________________________________

# Case with an external or manual creation of infectious status:

External or manual input:                   car
                                             │
Analyses:                  neg     neg       │    pos        neg        neg
                            ▼                ▼                           ▼
Infectious status:         nor              car                         nor
```
"""
function generateCarrierStatusesFromAnalyses end
function generateCarrierStatusesForEPC end
function getInfectiousStatusForListing end
