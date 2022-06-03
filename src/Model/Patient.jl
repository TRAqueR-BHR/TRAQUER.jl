mutable struct Patient <: IPatient 

  currentStatus::Union{Missing,Model.IPatientCurrentStatus}
  patientNameCrypt::Union{Missing,Model.IPatientNameCrypt}
  patientRefCrypt::Union{Missing,Model.IPatientRefCrypt}
  patientBirthdateCrypt::Union{Missing,Model.IPatientBirthdateCrypt}
  id::Union{Missing,String}
  traquerRef::Union{Missing,Int32}
  gender::Union{Missing,Gender.GENDER}
  analysisResults::Union{Missing,Vector{Model.IAnalysisResult}}
  infectiousStatuses::Union{Missing,Vector{Model.IInfectiousStatus}}
  stays::Union{Missing,Vector{Model.IStay}}
  contactContactExposures::Union{Missing,Vector{Model.IContactExposure}}
  carrierContactExposures::Union{Missing,Vector{Model.IContactExposure}}

  Patient(args::NamedTuple) = Patient(;args...)
  Patient(;
    currentStatus = missing,
    patientNameCrypt = missing,
    patientRefCrypt = missing,
    patientBirthdateCrypt = missing,
    id = missing,
    traquerRef = missing,
    gender = missing,
    analysisResults = missing,
    infectiousStatuses = missing,
    stays = missing,
    contactContactExposures = missing,
    carrierContactExposures = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.currentStatus = currentStatus
    x.patientNameCrypt = patientNameCrypt
    x.patientRefCrypt = patientRefCrypt
    x.patientBirthdateCrypt = patientBirthdateCrypt
    x.id = id
    x.traquerRef = traquerRef
    x.gender = gender
    x.analysisResults = analysisResults
    x.infectiousStatuses = infectiousStatuses
    x.stays = stays
    x.contactContactExposures = contactContactExposures
    x.carrierContactExposures = carrierContactExposures
    return x
  end

end 