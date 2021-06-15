mutable struct Patient <: IPatient

  id::Union{Missing,String}
  surname::Union{Missing,String}
  firstname::Union{Missing,String}
  gender::Union{Missing,Gender.GENDER}
  birthdate::Union{Missing,Date}
  fctUnitStaies::Union{Missing,Vector{Model.IFctUnitStay}}

  Patient(args::NamedTuple) = Patient(;args...)
  Patient(;
    id = missing,
    surname = missing,
    firstname = missing,
    gender = missing,
    birthdate = missing,
    fctUnitStaies = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,missing,);
    x.id = id;
    x.surname = surname;
    x.firstname = firstname;
    x.gender = gender;
    x.birthdate = birthdate;
    x.fctUnitStaies = fctUnitStaies;
    return x
  )

end
