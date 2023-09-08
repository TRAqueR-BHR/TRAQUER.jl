using CSV

include("cht-noumea-importStays.jl")
include("cht-noumea-importAnalyses.jl")
include("cht-noumea-checkIfNotAtRiskAnymore.jl")
include("convertETLInputDataToRequestAndResultType.jl")
include("convertETLInputDataToSampleMaterialType.jl")
include("getBasicInformationAboutStaysInputFile.jl")
include("getBasicInformationAboutAnalysesInputFile.jl")
include("getSummaryOfPendingInputFiles.jl")
