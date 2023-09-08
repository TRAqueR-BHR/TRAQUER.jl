function Custom.convertETLInputDataToSampleMaterialType(
    nature_code::String
)::SAMPLE_MATERIAL_TYPE
    return Custom.sampleMaterialTypeConversionDict[nature_code]
end
