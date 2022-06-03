mutable struct PatientCurrentStatus <: IPatientCurrentStatus 

  id::Union{Missing,String}
  hospitalizationStatus::Union{Missing,HospitalizationStatusType.HOSPITALIZATION_STATUS_TYPE}

  PatientCurrentStatus(args::NamedTuple) = PatientCurrentStatus(;args...)
  PatientCurrentStatus(;
    id = missing,
    hospitalizationStatus = missing,
  ) = begin
    x = new(missing,missing,)
    x.id = id
    x.hospitalizationStatus = hospitalizationStatus
    return x
  end

end 