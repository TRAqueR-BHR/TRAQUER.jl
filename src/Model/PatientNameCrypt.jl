mutable struct PatientNameCrypt <: IPatientNameCrypt 

  id::Union{Missing,String}
  lastnameFirstLetter::Union{Missing,String}
  firstnameCrypt::Union{Missing,Vector{UInt8}}
  lastnameForCpCrypt::Union{Missing,Vector{UInt8}}
  firstnameForCpCrypt::Union{Missing,Vector{UInt8}}
  lastnameCrypt::Union{Missing,Vector{UInt8}}
  patients::Union{Missing,Vector{Model.IPatient}}

  PatientNameCrypt(args::NamedTuple) = PatientNameCrypt(;args...)
  PatientNameCrypt(;
    id = missing,
    lastnameFirstLetter = missing,
    firstnameCrypt = missing,
    lastnameForCpCrypt = missing,
    firstnameForCpCrypt = missing,
    lastnameCrypt = missing,
    patients = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,missing,);
    x.id = id;
    x.lastnameFirstLetter = lastnameFirstLetter;
    x.firstnameCrypt = firstnameCrypt;
    x.lastnameForCpCrypt = lastnameForCpCrypt;
    x.firstnameForCpCrypt = firstnameForCpCrypt;
    x.lastnameCrypt = lastnameCrypt;
    x.patients = patients;
    return x
  )

end 