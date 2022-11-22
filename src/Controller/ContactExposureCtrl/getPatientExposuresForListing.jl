function ContactExposureCtrl.getPatientExposuresForListing(
    patient::Patient,
    encryptionStr::String,
    dbconn::LibPQ.Connection)::DataFrame

    exposures = PostgresORM.retrieve_entity(
        ContactExposure(contact = patient),
        false, # unit and outbreak details will get retrieved manually
        dbconn)

    exposuresDF = DataFrame()
    carrierDecryptDF = DataFrame()
    unitsDF = DataFrame()
    outbreaksDF = DataFrame()

    if isempty(exposures)
        return exposuresDF
    end

    for exposure in exposures

        # Add row to the exposures dataframe
        Base.push!(exposuresDF, exposure, dbconn)

        # Add row to the patient decrypt dataframe
        carrierDecrypt::PatientDecrypt = PatientCtrl.getPatientDecrypt(
            exposure.carrier,
            encryptionStr,
            dbconn
        )
        Base.push!(carrierDecryptDF, carrierDecrypt, dbconn)

        # Add row to the units dataframe
        unit = PostgresORM.retrieve_one_entity(Unit(id = exposure.unit.id),false,dbconn)
        passmissing(Base.push!)(unitsDF, unit, dbconn)

        # Add row to the outbreaks dataframe
        outbreak = PostgresORM.retrieve_one_entity(Outbreak(id = exposure.outbreak.id),false,dbconn)
        passmissing(Base.push!)(outbreaksDF, outbreak, dbconn)

    end

    # Underscore the column names
    DataFrames.rename!(exposuresDF, StringCases.underscore.(names(exposuresDF)))
    DataFrames.rename!(carrierDecryptDF, "carrier_" .* StringCases.underscore.(names(carrierDecryptDF)))
    DataFrames.rename!(unitsDF, "unit_" .* StringCases.underscore.(names(unitsDF)))
    DataFrames.rename!(outbreaksDF, "outbreak_" .* StringCases.underscore.(names(outbreaksDF)))

    # Make the joined DFs unique to avoid creating duplicates when doing the join
    unique!(carrierDecryptDF, :carrier_patient_id)
    unique!(unitsDF, :unit_id)
    unique!(exposuresDF, :outbreak_id)

    DataFrames.leftjoin!(exposuresDF, carrierDecryptDF, on = :carrier_id => :carrier_patient_id)
    DataFrames.leftjoin!(exposuresDF, unitsDF, on = :unit_id)
    DataFrames.leftjoin!(exposuresDF, outbreaksDF, on = :outbreak_id)

    return exposuresDF

end
