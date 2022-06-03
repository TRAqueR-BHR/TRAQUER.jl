include("prerequisite-initialize-db-with-demo-data.jl")

include("1-initialize-db-with-demo-patients.jl")
include("1-initialize-db-with-demo-units.jl")

encryptionStr = getDefaultEncryptionStr()

demoStays = Stay[]
TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

    for r in eachrow(staysDF)
        StayCtrl.createStayIfNotExists(
            demoPatients[r.patientRef],
            demoUnits[r.unitRef],
            r.inZDT,
            r.outZDT,
            r.hospiDate,
            dbconn)
    end

end
