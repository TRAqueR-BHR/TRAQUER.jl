module SampleMaterialType
  export SAMPLE_MATERIAL_TYPE
  @enum SAMPLE_MATERIAL_TYPE begin
    purulent_collection = 1 
    actinomycetes = 2 
    joint_liquid = 3 
    ascites_liquid = 4 
    broncho_tracheal_aspiration = 5 
    bronchial_aspiration = 6 
    tracheal_aspiration = 7 
    biopsy_fragment = 8 
    biliary_liquid = 9 
    mouth = 10 
    bronchial_brushing = 11 
    fungal_mapping = 12 
    implantable_chamber_pac = 13 
    conjunctiva = 14 
    cornea = 15 
    sputum = 16 
    cryptococcus = 17 
    miscellaneous = 18 
    dpc_liquid = 19 
    dpc_microbiology = 20 
    intra_tissular_device = 21 
    intra_cavitary_device = 22 
    throat_tonsils = 23 
    gynecological_pelvic = 24 
    blood_culture = 25 
    pediatric_blood_culture = 26 
    unspecified_nature_sample = 27 
    intravascular_device = 28 
    broncho_alveolar_lavage = 29 
    biological_liquid = 30 
    csf_chemistry_serology = 31 
    csf_bacterial = 32 
    gastric_liquid = 33 
    amniotic_liquid = 34 
    lochial = 35 
    pleural_liquid = 36 
    pericardial_liquid = 37 
    mycobacterium = 38 
    nose = 39 
    placenta = 40 
    external_ear = 41 
    middle_ear = 42 
    ears = 43 
    bone = 44 
    puncture = 45 
    skin_or_appendages = 46 
    skin = 47 
    peritoneal_liquid = 48 
    pica_liquid = 49 
    wound_or_oozing = 50 
    blood_bag_and_tubings = 51 
    sinus_puncture = 52 
    urethral_sampling = 53 
    superficial_pus = 54 
    rectal_swab = 55 
    respiratory = 56 
    indwelling_urinary_catheter = 57 
    stool = 58 
    bacterial_strain = 59 
    semen = 60 
    scales = 61 
    iud = 62 
    tissue = 63 
    transmitted_sample = 64 
    protected_tracheal_aspiration = 65 
    urine = 66 
    urine_b = 67 
    resistant_screening_swabs = 68 
    cancelled = 69 
  end
end

module OutbreakCriticity
  export OUTBREAK_CRITICITY
  @enum OUTBREAK_CRITICITY begin
    epidemic = 1 
    non_epidemic = 2 
    dont_know = 3 
  end
end

module AnalysisRequestStatusType
  export ANALYSIS_REQUEST_STATUS_TYPE
  @enum ANALYSIS_REQUEST_STATUS_TYPE begin
    requested = 1 
    in_progress = 2 
    done = 3 
  end
end

module AnalysisRequestType
  export ANALYSIS_REQUEST_TYPE
  @enum ANALYSIS_REQUEST_TYPE begin
    molecular_analysis_carbapenemase_producing_enterobacteriaceae = 1 
    bacterial_culture_carbapenemase_producing_enterobacteriaceae = 2 
    molecular_analysis_vancomycin_resistant_enterococcus = 3 
    bacterial_culture_vancomycin_resistant_enterococcus = 4 
  end
end

module ResponseType
  export RESPONSE_TYPE
  @enum RESPONSE_TYPE begin
    acknowledge = 1 
    confirm = 2 
    request_analysis = 3 
    send_a_reminder = 4 
    associate_to_existing_outbreak = 5 
    declare_outbreak = 6 
    isolation_in_same_unit = 7 
    isolation_in_special_unit = 8 
    delete_infectious_status = 9 
  end
end

module InfectiousAgentCategory
  export INFECTIOUS_AGENT_CATEGORY
  @enum INFECTIOUS_AGENT_CATEGORY begin
    carbapenemase_producing_enterobacteriaceae = 1 
    vancomycin_resistant_enterococcus = 2 
  end
end

module InfectiousStatusType
  export INFECTIOUS_STATUS_TYPE
  @enum INFECTIOUS_STATUS_TYPE begin
    not_at_risk = 1 
    carrier = 2 
    contact = 3 
    suspicion = 4 
  end
end

module AnalysisResultValueType
  export ANALYSIS_RESULT_VALUE_TYPE
  @enum ANALYSIS_RESULT_VALUE_TYPE begin
    positive = 1 
    negative = 2 
    cancelled = 3 
    suspicion = 4 
  end
end

module AppuserType
  export APPUSER_TYPE
  @enum APPUSER_TYPE begin
    technical_administrator = 1 
    staff_member = 2 
  end
end

module Gender
  export GENDER
  @enum GENDER begin
    male = 1 
    female = 2 
  end
end

module HospitalizationStatusType
  export HOSPITALIZATION_STATUS_TYPE
  @enum HOSPITALIZATION_STATUS_TYPE begin
    in = 1 
    out = 2 
    forthcoming = 3 
  end
end

module RoleCodeName
  export ROLE_CODE_NAME
  @enum ROLE_CODE_NAME begin
    technical_administrator = 1 
    staff_member = 2 
    doctor = 3 
    caregiver = 4 
    nurse = 5 
    secretary = 6 
    biologist = 7 
    software_administrator = 8 
    is_doctor = 9 
    is_nurse = 10 
    can_modify_user = 11 
    staff_member_with_extended_permissions = 12 
  end
end

module EventRequiringAttentionType
  export EVENT_REQUIRING_ATTENTION_TYPE
  @enum EVENT_REQUIRING_ATTENTION_TYPE begin
    new_status = 1 
    analysis_in_progress = 2 
    analysis_done = 3 
    analysis_late = 4 
    new_stay = 5 
    death = 6 
    transfer_to_another_care_facility = 7 
  end
end

