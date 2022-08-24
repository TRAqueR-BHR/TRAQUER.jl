mutable struct Patient <: IPatient 

  currentUnit::Union{Missing,Model.IUnit}
  patientNameCrypt::Union{Missing,Model.IPatientNameCrypt}
  patientRefCrypt::Union{Missing,Model.IPatientRefCrypt}
  patientBirthdateCrypt::Union{Missing,Model.IPatientBirthdateCrypt}
  id::Union{Missing,String}
  isHospitalized::Union{Missing,Bool}
  traquerRef::Union{Missing,Int32}
  gender::Union{Missing,Gender.GENDER}
  analysisResults::Union{Missing,Vector{Model.IAnalysisResult}}
  infectiousStatuses::Union{Missing,Vector{Model.IInfectiousStatus}}
  staies::Union{Missing,Vector{Model.IStay}}
  contactContactExposures::Union{Missing,Vector{Model.IContactExposure}}
  carrierContactExposures::Union{Missing,Vector{Model.IContactExposure}}

  Patient(args::NamedTuple) = Patient(;args...)
  Patient(;
    currentUnit = missing,
    patientNameCrypt = missing,
    patientRefCrypt = missing,
    patientBirthdateCrypt = missing,
    id = missing,
    isHospitalized = missing,
    traquerRef = missing,
    gender = missing,
    analysisResults = missing,
    infectiousStatuses = missing,
    staies = missing,
    contactContactExposures = missing,
    carrierContactExposures = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.currentUnit = currentUnit
    x.patientNameCrypt = patientNameCrypt
    x.patientRefCrypt = patientRefCrypt
    x.patientBirthdateCrypt = patientBirthdateCrypt
    x.id = id
    x.isHospitalized = isHospitalized
    x.traquerRef = traquerRef
    x.gender = gender
    x.analysisResults = analysisResults
    x.infectiousStatuses = infectiousStatuses
    x.staies = staies
    x.contactContactExposures = contactContactExposures
    x.carrierContactExposures = carrierContactExposures
    return x
  end

end 