include("../../../test/runtests-prerequisite.jl")


dfAnalyses = DataFrame(
    XLSX.readtable("custom/Demo/test/sample-input-data/demo-analyses.xlsx",1))
TRAQUER.Custom.importAnalyses(dfAnalyses, getDefaultEncryptionStr())
