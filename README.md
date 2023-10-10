# TRAQUER.jl

An event (`EventRequiringAttention`) is alway related to an infectious status (`InfectiousStatus`).
An infectious status can be related to zero, one or multiple outbreaks via instances of
`OutbreakInfectiousStatusAsso` (Eg. of multiple associations, one outbreak for the
hospitalization where the patient was found positive ; another outbreak for a new hospitalization
of that same patient).

An infectious status (`InfectiousStatus`) are used to deduce the stays where the patient are
at risk using function `
        StayCtrl.getStaysWherePatientAtRisk(
            atRiskStatus::InfectiousStatus,
            dbconn::LibPQ.Connection
        )`


## Scheduler

### Permanently Add/Remove
To add/remove a function or change the timing of execution of a scheduled function. No need
to restart the application, you can just restart the scheduler
```
TRAQUER.stopScheduler()
TRAQUER.startScheduler()
```

### Enable/Disable a function
To enable/disable a function for an environment, do not remove it from the code, use the
blacklist in the configuration file (`scheduler.blacklist`).

**NOTE:** No need to restart the scheduler.
