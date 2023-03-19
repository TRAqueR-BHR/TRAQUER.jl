include("../../../test/runtests-prerequisite.jl")

beginningOfTime = now(TRAQUERUtil.getTimeZone()) - Day(2)
rand(1:10)

unitsDF = DataFrame(
    unitCodeName = ["rea_chir","rea","cardio"],
    unitName = ["Réanimations chirurgicales","Réanimation","Cardiologie"]
)
patientsDF = DataFrame(
    firstname = ["André","Murielle"],
    lastname = ["Dupont","Poirier"],
    birthdate = [Date("1990-09-01"), Date("1987-02-01")],
    ref=["patient1","patient2"],
)
staysDF = DataFrame(
    patientRef = Vector{Union{Missing,String}}(),
    unitRef = Vector{Union{Missing,String}}(),
    inZDT = Vector{Union{Missing,ZonedDateTime}}(),
    outZDT = Vector{Union{Missing,ZonedDateTime}}(),
    hospiDate= Vector{Union{Missing,Date}}(),
)
append!(
    staysDF,
    (
        patientRef = "patient1",
        unitRef = "rea_chir",
        inZDT = beginningOfTime - Day(3), # in
        outZDT = beginningOfTime - Day(1), # out
        hospiDate = beginningOfTime - Day(3) |> Date # hospitalizationDate
        ) |> PostgresORM.PostgresORMUtil.namedtuple2dict |> DataFrame
)
append!(
    staysDF,
    (
        patientRef = "patient1",
        unitRef = "rea",
        inZDT = beginningOfTime - Day(1), # in
        outZDT = missing, # out
        hospiDate = beginningOfTime - Day(3) |> Date # hospitalizationDate
        ) |> PostgresORM.PostgresORMUtil.namedtuple2dict |> DataFrame
)
