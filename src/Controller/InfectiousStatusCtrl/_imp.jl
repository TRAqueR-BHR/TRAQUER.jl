include("checkIfPatientIsCarrierAtTime.jl")
include("defaultCheckIfNotAtRiskAnymore.jl")
include("getInfectiousStatusForListing.jl")
include("getInfectiousStatuses.jl")
include("getInfectiousStatusesAtTime.jl")
include("getInfectiousStatusAtTime.jl")
include("generateCarrierStatusesFromAnalyses.jl")
include("generateNotAtRiskStatusForDeadPatient.jl")
include("generateContactStatusFromExposure.jl")
include("generateNotAtRiskStatusesFromAnalyses.jl")
include("updateCurrentStatus.jl")
include("updateOutbreakInfectiousStatusAssos.jl")
include("upsert.jl")
include("delete.jl")
include("generateSuspicionStatusesFromAnalyses.jl")
include("getInfectiousStatusesOfInterestOverPeriod.jl")
include("getTimeWherePatientBecameCarrierOrSuspicion.jl")
