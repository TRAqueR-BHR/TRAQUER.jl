using CSV

include("cht-noumea-importStays.jl")
include("cht-noumea-importAnalyses.jl")
include("cht-noumea-checkIfNotAtRiskAnymore.jl")
include("convertETLInputDataToRequestAndResultType.jl")
include("convertStringInInputFileToANALYSIS_REQUEST_TYPE.jl")
include("convertStringInInputFileToANALYSIS_RESULT_VALUE_TYPE.jl")
include("getBasicInformationAboutStaysInputFile.jl")
include("getBasicInformationAboutAnalysesInputFile.jl")
include("getSummaryOfPendingInputFiles.jl")
