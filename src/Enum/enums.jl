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

module RoleCodeName
  export ROLE_CODE_NAME
  @enum ROLE_CODE_NAME begin
    healthcare_professional = 1
    can_modify_user = 2
    doctor = 3
  end
end

module CarrierContact
  export CARRIER_CONTACT
  @enum CARRIER_CONTACT begin
    carrier = 1
    contact = 2
  end
end
