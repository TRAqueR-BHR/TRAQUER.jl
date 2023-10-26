function processNewlyIntegratedData end
function getMaxProcessingTime end
function updateMaxProcessingTime end
function checkIfAnythingNeedsToBeExecuted end
function checkIfNeedsToExecuteFunction end
function getLastExecution end

every1Minutes = collect(Time("00:00:00"):Minute(1):Time("23:59:00"))
every2Minutes = collect(Time("00:00:00"):Minute(2):Time("23:59:00"))
every5Minutes = collect(Time("00:00:00"):Minute(5):Time("23:59:00"))
every10Minutes = collect(Time("00:00:00"):Minute(10):Time("23:59:00"))
every15Minutes = collect(Time("00:00:00"):Minute(15):Time("23:59:00"))
every20Minutes = collect(Time("00:00:00"):Minute(20):Time("23:59:00"))
every30Minutes = collect(Time("00:00:00"):Minute(30):Time("23:59:00"))
every60Minutes = collect(Time("00:00:00"):Minute(60):Time("23:59:00"))
every2Hours = collect(Time("00:00:00"):Hour(2):Time("23:59:00"))
