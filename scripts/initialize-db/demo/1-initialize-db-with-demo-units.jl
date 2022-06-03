include("prerequisite-initialize-db-with-demo-data.jl")

encryptionStr = getDefaultEncryptionStr()

demoUnits = Dict{String,Unit}()

TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

    for r in eachrow(unitsDF)
        push!(
            demoUnits,
            r.unitCodeName => UnitCtrl.createUnitIfNotExists(r.unitCodeName,r.unitName,dbconn)
        )
    end

end
