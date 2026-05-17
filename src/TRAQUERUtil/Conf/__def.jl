export loadConf, hasConf, getConf, updateConf, getTimeZone, getTimeZoneAsStr,
       getInstanceCodeName, blindBakeIsRequired,
       resetDatabaseIsAllowed, getDataDir, getPendingInputFilesDir,
       getProcessingInputFilesDir, getDoneInputFilesDir,
       getInputFilesProblemsDir, noEmail, getTeamEmailAddress,
       getAdminEmail, bccAdminForEveryEmail, getInstancePrettyName,
       getCarrierWaitingPeriod, getNumberOfNegativeTestsForCarrierExclusion,
       getMinimumNumberOfHoursForContactStatusCreation,
       getNumberOfNegativeTestsForContactExclusion

function loadConf end
function hasConf end
function getConf end
function updateConf end

include("default/__def.jl")
include("custom/__def.jl")
include("rules_parameters/__def.jl")
include("admin/__def.jl")
include("security/__def.jl")
include("database/__def.jl")
include("email/__def.jl")
include("debug/__def.jl")
include("s3/__def.jl")
