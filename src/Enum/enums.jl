module AppuserType
  export APPUSER_TYPE
  @enum APPUSER_TYPE begin
    healthcare_professional = 1 
  end
end

module InfectiousAgentCodeName
  export INFECTIOUS_AGENT_CODE_NAME
  @enum INFECTIOUS_AGENT_CODE_NAME begin
    arb_grb = 1 
    arb_cpe = 2 
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

module InfectiousStatusType
  export INFECTIOUS_STATUS_TYPE
  @enum INFECTIOUS_STATUS_TYPE begin
    excluded = 1 
    carrier = 2 
    contact = 3 
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

