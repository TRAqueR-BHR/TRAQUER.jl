# Description of 'analyses' Parquet file

This file contains the description of the 'analyses' Parquet file.
Several lines can refer to the same analysis,
Eg. one line for the request and one line for the result.

## Column: patientFirstname
- Type: String
- Optional: No

## Column: patientLastname
- Type: String
- Optional: No

## Column: patientBirthdate
- Type: Date
- Optional: No

## Column: patientRef
- Type: String
- Optional: No

## Column: analysisRef
- Type: String
- Optional: No

## Column: requestTime
- Type: DateTime
- Optional: No
- Note: In the timezone of the hospital

## Column: requestType
- Type: String (converted to enum ANALYSIS_REQUEST_TYPE)
- Optional: No
- Allowed Values:
  - molecular_analysis_carbapenemase_producing_enterobacteriaceae
  - bacterial_culture_carbapenemase_producing_enterobacteriaceae
  - molecular_analysis_vancomycin_resistant_enterococcus
  - bacterial_culture_vancomycin_resistant_enterococcus

## Column: sampleMaterialType
- Type: String (converted to enum SAMPLE_MATERIAL_TYPE)
- Optional: Yes
- Note: The list of allowed values can be extended
- Allowed Values:
  - purulent_collection
  - actinomycetes
  - joint_liquid
  - ascites_liquid
  - broncho_tracheal_aspiration
  - bronchial_aspiration
  - tracheal_aspiration
  - biopsy_fragment
  - biliary_liquid
  - mouth
  - bronchial_brushing
  - fungal_mapping
  - implantable_chamber_pac
  - conjunctiva
  - cornea
  - sputum
  - cryptococcus
  - miscellaneous
  - dpc_liquid
  - dpc_microbiology
  - intra_tissular_device
  - intra_cavitary_device
  - throat_tonsils
  - gynecological_pelvic
  - blood_culture
  - pediatric_blood_culture
  - unspecified_nature_sample
  - intravascular_device
  - broncho_alveolar_lavage
  - biological_liquid
  - csf_chemistry_serology
  - csf_bacterial
  - gastric_liquid
  - amniotic_liquid
  - lochial
  - pleural_liquid
  - pericardial_liquid
  - mycobacterium
  - nose
  - placenta
  - external_ear
  - middle_ear
  - ears
  - bone
  - puncture
  - skin_or_appendages
  - skin
  - peritoneal_liquid
  - pica_liquid
  - wound_or_oozing
  - blood_bag_and_tubings
  - sinus_puncture
  - urethral_sampling
  - superficial_pus
  - rectal_swab
  - respiratory
  - indwelling_urinary_catheter
  - stool
  - bacterial_strain
  - semen
  - scales
  - iud
  - tissue
  - transmitted_sample
  - protected_tracheal_aspiration
  - urine
  - urine_b
  - resistant_screening_swabs
  - cancelled

## Column: resultTime
- Type: DateTime
- Optional: Yes
- Note: In the timezone of the hospital

## Column: result
- Type: String (converted to enum ANALYSIS_RESULT_VALUE_TYPE)
- Optional: Yes
- Allowed Values:
  - positive
  - negative
  - cancelled
  - suspicion

## Column: bacteriaName
- Type: String
- Optional: Yes

