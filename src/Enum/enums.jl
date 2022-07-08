module SampleMaterialType
  export SAMPLE_MATERIAL_TYPE
  @enum SAMPLE_MATERIAL_TYPE begin
    faeces = 1 
    urine = 2 
    heart_blood = 3 
    peripheral_blood = 4 
    saliva = 5 
    heart = 6 
    thoracic_aorta = 7 
    abdominal_aorta = 8 
    esophagus = 9 
    trachea = 10 
    stomach = 11 
    digestive_tract = 12 
    prostate = 13 
    uterus = 14 
    ovaries = 15 
    adrenal_glands = 16 
    liver = 17 
    brain = 18 
    rein = 19 
    lung = 20 
    bone_marrow = 21 
    spinal_cord = 22 
    bone = 23 
    muscle = 24 
    skin = 25 
    laringo = 26 
    spleen = 27 
    pancreas = 28 
    nails = 29 
    gastric_contents = 30 
    unidentified_liquid = 31 
    vitreous_humour = 32 
    hair = 33 
    bile = 34 
    textile = 35 
    prosthetic_material = 36 
    ballistic_material = 37 
    other = 38 
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
  end
end

module AnalysisResultValueType
  export ANALYSIS_RESULT_VALUE_TYPE
  @enum ANALYSIS_RESULT_VALUE_TYPE begin
    positive = 1 
    negative = 2 
  end
end

module AppuserType
  export APPUSER_TYPE
  @enum APPUSER_TYPE begin
    healthcare_professional = 1 
  end
end

module Gender
  export GENDER
  @enum GENDER begin
    male = 1 
    female = 2 
  end
end

module InfectiousStatusEventResponseType
  export INFECTIOUS_STATUS_EVENT_RESPONSE_TYPE
  @enum INFECTIOUS_STATUS_EVENT_RESPONSE_TYPE begin
    acknowledge = 1 
    confirm = 2 
    request_analysis = 3 
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

module InfectiousStatusEventType
  export INFECTIOUS_STATUS_EVENT_TYPE
  @enum INFECTIOUS_STATUS_EVENT_TYPE begin
    hospitalization = 1 
    new_status = 2 
    analysis_in_progress = 3 
    analysis_done = 4 
  end
end

module RoleCodeName
  export ROLE_CODE_NAME
  @enum ROLE_CODE_NAME begin
    healthcare_professional = 1 
    can_modify_user = 2 
    doctor = 3 
  end
end

