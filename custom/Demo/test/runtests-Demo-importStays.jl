include("../../../test/runtests-prerequisite.jl")

dfStays = DataFrame(
    XLSX.readtable("custom/Demo/test/sample-input-data/demo-stays.xlsx",1)...)
TRAQUER.Custom.importStays(dfStays,getDefaultEncryptionStr())
