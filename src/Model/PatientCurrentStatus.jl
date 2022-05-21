mutable struct PatientCurrentStatus <: IPatientCurrentStatus 

  id::Union{Missing,String}
  infectiousStatus::Union{Missing,InfectiousStatusType.INFECTIOUS_STATUS_TYPE}
  contactFor::Union{Missing,Vector{InfectiousAgentCodeName.INFECTIOUS_AGENT_CODE_NAME}}
  carrierFor::Union{Missing,Vector{InfectiousAgentCodeName.INFECTIOUS_AGENT_CODE_NAME}}
  hospitalizationStatus::Union{Missing,HospitalizationStatusType.HOSPITALIZATION_STATUS_TYPE}

  PatientCurrentStatus(args::NamedTuple) = PatientCurrentStatus(;args...)
  PatientCurrentStatus(;
    id = missing,
    infectiousStatus = missing,
    contactFor = missing,
    carrierFor = missing,
    hospitalizationStatus = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,)
    x.id = id
    x.infectiousStatus = infectiousStatus
    x.contactFor = contactFor
    x.carrierFor = carrierFor
    x.hospitalizationStatus = hospitalizationStatus
    return x
  end

end 