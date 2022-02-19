mutable struct PatientRefCrypt <: IPatientRefCrypt 

  id::Union{Missing,String}
  oneChar::Union{Missing,String}
  refCrypt::Union{Missing,Vector{UInt8}}
  patients::Union{Missing,Vector{Model.IPatient}}

  PatientRefCrypt(args::NamedTuple) = PatientRefCrypt(;args...)
  PatientRefCrypt(;
    id = missing,
    oneChar = missing,
    refCrypt = missing,
    patients = missing,
  ) = (
    x = new(missing,missing,missing,missing,);
    x.id = id;
    x.oneChar = oneChar;
    x.refCrypt = refCrypt;
    x.patients = patients;
    return x
  )

end 