include("upsert.jl")
include("createNewStayEventIfPatientAtRisk.jl")
include("createAnalysisDoneEventIfNeeded.jl")
include("createAnalysisLateEvent.jl")
include("createEventsTransferToAnotherCareFacility.jl")
include("notifyTeamOfNewImportantEvents.jl")
include("getNewImportantEvents.jl")
include("requiresTeamNotification.jl")
include("createSummaryOfEvents.jl")
