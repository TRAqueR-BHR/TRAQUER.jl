function loadConf end
function hasConf end
function getConf end
function openDBConn end
function openDBConnAndBeginTransaction end
function beginDBTransaction end
function commitDBTransaction end
function rollbackDBTransaction end
function closeDBConn end
function getInstanceCodeName end
function getCryptPwdHttpHeaderKey end
function convertStringToZonedDateTime end
function createPartitionPatientRefIfNotExist end
function createPartitionPatientBirthdateIfNotExist end
function createPartitionPatientNameIfNotExist end
function createPartitionAnalysisRefIfNotExist end
function createPartitionStayIfNotExist end
function createPartitionContactExposureIfNotExist end
function createPartitionAnalysisResultIfNotExist end
function getTablePartitionNameOnYearMonth end
function createTablePartitionOnYearMonth end
function createTablePartitionsOnYearMonthForGivenYear end
function createTablesPartitionsOnYearMonthForLastYears end
function blindBakeIsRequired end
function listEnums end

function rmAccentsAndLowercase end
function cleanStringForEncryptedValueCp end
function normalizeWhites end
function removeDoubleSpaces end
function removeDoubleLineReturns end
function formatExceptionAndStackTrace end
function formatExceptionAndStackTraceCore end
function updateConf end
function getTimeZone end
function getTimeZoneAsStr end
function string2enum end
function string2date end
function nowInTargetTimeZone end
function resetDatabaseIsAllowed end

function generateHumanReadableUniqueRef end
function retrieveSequenceNextval end

function initialize_http_response_status_code end
function getCurrentFrontendVersion end
function json2Entity end

function extractCryptPwdFromHTTPHeader end

function createDBConnAndExecute end
function createDBConnAndExecuteWithTransaction end
function executeOnWorkerTwoOrHigher end
function executeOnBgThread end

function getMappingAnalysisRequestType2InfectiousAgentCategory end
function analysisRequestType2InfectiousAgentCategory end
function infectiousAgentCategory2AnalysisRequestTypes end

function getCarrierWaitingPeriod end
function getNumberOfNegativeTestsForCarrierExclusion end
function getMinimumNumberOfHoursForContactStatusCreation end
function getNumberOfNegativeTestsForContactExclusion end

function string2enum end
function string2enum end
function int2enum end
function int2enum end
function string2number end
function string2number end
function string2type end
function string2bool end
function json2entity end
function browserDateString2date end
function browserDateString2ZonedDateTime end
function isMissingOrNothing end
function copyLinesToDestFile end
function readFirstNLinesOfFile end
function readFirstNLinesOfCSVFile end
function readLineXOfFile end
# function addDataFrameRow
function dumpDatabase end
function noEmail end
function getDataDir end
function getPendingInputFilesDir end
function getProcessingInputFilesDir end
function getDoneInputFilesDir end
function getInstancePrettyName end
function getInputFilesProblemsDir end
function moveStaysInputFileToDoneDir end
function moveAnalysesInputFileToDoneDir end
function moveInputFileToProcessingDir end

function getSchedulerBlacklist end
function getJuliaFunction end

function dumpDatabase end
function cleanOldDatabaseDumps end
function dumpDatabaseAndCleanOldDumps end
function getDatabaseDumpRetentionPeriod end

function sendemail end
function getAdminEmail end
function bccAdminForEveryEmail end
