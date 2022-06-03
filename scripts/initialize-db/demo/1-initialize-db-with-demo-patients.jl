include("prerequisite-initialize-db-with-demo-data.jl")

encryptionStr = getDefaultEncryptionStr()

demoPatients = Dict{String,Patient}()

TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

    for r in eachrow(patientsDF)
        push!(
            demoPatients,
            r.ref => PatientCtrl.createPatientIfNoExist(
                r.firstname,
                r.lastname,
                r.birthdate,
                r.ref,
                encryptionStr,
                dbconn)
            )
    end

end
