mutable struct Patient <: IPatient 

  currentStatus::Union{Missing,Model.IPatientCurrentStatus}
  patientNameCrypt::Union{Missing,Model.IPatientNameCrypt}
  patientRefCrypt::Union{Missing,Model.IPatientRefCrypt}
  patientBirthdateCrypt::Union{Missing,Model.IPatientBirthdateCrypt}
  id::Union{Missing,String}
  traquerRef::Union{Missing,Int32}
  gender::Union{Missing,Gender.GENDER}
  infectiousStatuses::Union{Missing,Vector{Model.IInfectiousStatus}}
  stays::Union{Missing,Vector{Model.IStay}}
  analyses::Union{Missing,Vector{Model.IAnalysis}}
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
    infectiousStatuses = missing,
    stays = missing,
    analyses = missing,
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
    x.infectiousStatuses = infectiousStatuses
    x.stays = stays
    x.analyses = analyses
    x.contactContactExposures = contactContactExposures
    x.carrierContactExposures = carrierContactExposures
    return x
  end

end 