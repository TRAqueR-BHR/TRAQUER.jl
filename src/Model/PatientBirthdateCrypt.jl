mutable struct PatientBirthdateCrypt <: IPatientBirthdateCrypt 

  id::Union{Missing,String}
  year::Union{Missing,Int16}
  birthdateCrypt::Union{Missing,Vector{UInt8}}
  patients::Union{Missing,Vector{Model.IPatient}}

  PatientBirthdateCrypt(args::NamedTuple) = PatientBirthdateCrypt(;args...)
  PatientBirthdateCrypt(;
    id = missing,
    year = missing,
    birthdateCrypt = missing,
    patients = missing,
  ) = (
    x = new(missing,missing,missing,missing,);
    x.id = id;
    x.year = year;
    x.birthdateCrypt = birthdateCrypt;
    x.patients = patients;
    return x
  )

end 