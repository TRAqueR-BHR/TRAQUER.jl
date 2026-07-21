export loadConf, hasConf, getConf, updateConf, getTimeZone, getTimeZoneAsStr,
       getInstanceCodeName, blindBakeIsRequired,
       resetDatabaseIsAllowed, getFSDataDir, getFSPendingInputFilesDir,
       getFSProcessingInputFilesDir, getFSDoneInputFilesDir,
       getFSInputFilesProblemsDir, noEmail, requiresSMTPAuthentication,
       isSendEmailOverTLSConnection, getEmailFromAddress, getEmailSmtpServer,
       getEmailUserid, getEmailUserpwd,
       getSlackWebhookUrl, getSlackToken, getSlackChannel,
       slackIsConfigured, getTeamEmailAddress,
       getAdminEmail, bccAdminForEveryEmail, getInstancePrettyName,
       getCarrierWaitingPeriod, getNumberOfNegativeTestsForCarrierExclusion,
       getMinimumNumberOfHoursForContactStatusCreation,
       getNumberOfNegativeTestsForContactExclusion,
       getS3Url, getS3Region, getS3AccessKey, getS3SecretKey,
       getS3HospitalBucket

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
include("slack/__def.jl")
include("fs-path/__def.jl")
include("debug/__def.jl")
include("s3/__def.jl")
include("s3-path/__def.jl")
include("redis/__def.jl")
include("redis/__imp.jl")
