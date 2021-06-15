mutable struct Patient <: IPatient 

  id::Union{Missing,String}
  surname::Union{Missing,String}
  firstname::Union{Missing,String}
  gender::Union{Missing,Gender.GENDER}
  birthdate::Union{Missing,Date}
  labAnalysiss::Union{Missing,Vector{Model.ILabAnalysis}}
  fctUnitStaies::Union{Missing,Vector{Model.IFctUnitStay}}

  Patient(args::NamedTuple) = Patient(;args...)
  Patient(;
    id = missing,
    surname = missing,
    firstname = missing,
    gender = missing,
    birthdate = missing,
    labAnalysiss = missing,
    fctUnitStaies = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,missing,);
    x.id = id;
    x.surname = surname;
    x.firstname = firstname;
    x.gender = gender;
    x.birthdate = birthdate;
    x.labAnalysiss = labAnalysiss;
    x.fctUnitStaies = fctUnitStaies;
    return x
  )

end 