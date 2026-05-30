mutable struct PatientDecrypt <: IPatientDecrypt

  patientId::Union{Missing,String}
  firstname::Union{Missing,String}
  lastname::Union{Missing,String}
  birthdate::Union{Missing,Date}
  patientRef::Union{Missing,String} # patient reference in the hospital info. system (IPP or equivalent)

  PatientDecrypt(args::NamedTuple) = PatientDecrypt(;args...)
  PatientDecrypt(;
  patientId = missing,
    firstname = missing,
    lastname = missing,
    birthdate = missing,
    patientRef = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing);
    x.patientId = patientId;
    x.firstname = firstname;
    x.lastname = lastname;
    x.birthdate = birthdate;
    x.patientRef = patientRef;

    return x
  )

end
