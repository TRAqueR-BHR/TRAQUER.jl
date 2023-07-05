include("../../../test/runtests-prerequisite.jl")


dfAnalyses = DataFrame(
    # XLSX.readtable("custom/demo/test/sample-input-data/demo-analyses.xlsx",1)
    XLSX.readtable("custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-analyses SALIOU.XLSX",1)
)
TRAQUER.Custom.importAnalyses(dfAnalyses, getDefaultEncryptionStr())
