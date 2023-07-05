using Pkg
Pkg.activate(".")

using Revise
using TRAQUER
using TRAQUER.Model
using TRAQUER.TRAQUERUtil
using TRAQUER.Controller
using PostgresORM
using CSV
using DataFrames
using TimeZones
using Dates
using Test
using Distributed


TRAQUERUtil.getConf("database","port")
TRAQUERUtil.openDBConn()

@info LOAD_PATH

@test 2==2
Dates.Date()
println()
DataFrames.innerjoin()
TRAQUER.greet()
TRAQUER.greet()
TRAQUER.Model.Patient()
PostgresORM.create_entity!()

patient3 = TRAQUER.Model.Patient(firstname="Laure",)


patient2.surname="Provert"

patient3.gender=TRAQUER.Enums.Gender.female
TRAQUER.DAO.FctUnitDAO.get_table_name()

PostgresORM.Controller.create_entity!(patient, dbconn)
using PostgresORM
using LibPQ


dbconn=
   TRAQUERUtil.opendbconn()

PostgresORM.Controller.create_entity!(patient1, dbconn)
PostgresORM.Controller.update_entity!(patient2, dbconn)

TRAQUERUtil.closedbconn(dbconn)

dxcare = CSV.read("csv/mouvements DXCARE 202009-202010.csv", DataFrame)

#outdir = "/home/medi/Documents/Code/TRAQUER.jl/misc/reverse-engineering/out"
#PostgresORM.Tool.generate_julia_code(dbconn, outdir ;module_name_for_all_schemas = "Model")

dateStr = "07/10/2020"
timeStr = "445"

dateDate = Date(dateStr,DateFormat("d/m/y"))

timeTime = begin

   timeTemp = missing

   if length(timeStr) == 1
      timeTemp = Time(timeStr, DateFormat("M"))
   end

   if length(timeStr) == 2
      timeTemp = Time(timeStr, DateFormat("MM"))
   end


   if length(timeStr) == 3
      timeTemp = Time(timeStr, DateFormat("HMM"))
   end

   if length(timeStr) == 4
      timeTemp = Time(timeStr, DateFormat("HHMM"))
   end
   timeTemp

end

typeof(timeTime)


dateTimes = DateTime(dateDate,timeTime)


inDateTest =  ZonedDateTime(dateTimes,tz"Europe/Warsaw")
typeof(tz"Europe/Warsaw")

typeof(inDateTest)

toto = [4,5]

"lineCounter = $(toto[2])"
toto = 4

query = "select * from patient where patient.birthdate = \$1"
args = [Date("1969-08-28")]
dbconn = TRAQUERUtil.opendbconn()

PostgresORM.Controller.execute_query_and_handle_result(query,Patient,args,false,dbconn)


toto = XLSX.readxlsx("csv/Untitled 1.xlsx")
typeof(toto["Sheet1"])
names(df)
df = DataFrame(XLSX.readtable("csv/Untitled 1.xlsx", "Sheet1")...)

tata = (XLSX.readtable("csv/Untitled 1.xlsx", "Sheet1")...)


dateDemande = string("05/10/1999")
heureDemande = string("000")
timeZoned = tz"Europe/Paris"

dateHeureDemandes =
TRAQUERUtil.convertStringToZonedDateTime(dateDemande,heureDemande,
                                             timeZone)
str="23:59"
Time(str, DateFormat("HH:MM"))


query = "select * from fct_unit_stay where between fct_unit_stay.in_time
         and fct_unit_stay.out_time =\$1"
args = [dateHeureDemande]

PostgresORM.Controller.execute_query_and_handle_result(query,Patient, args,
                                                         false,dbconn)


let
   currentYear = Dates.year(today())
   for i in 0:5
      @info currentYear - i
      @info typeof(currentYear - i)
   end
end

let
_tables = [("public","stay"),
          ("public","analyis")]
    for _table in _tables
      @info "$(first(_table)) $(last(_table))"
    end

end

dbconn = TRAQUERUtil.openDBConn()
patient = PostgresORM.retrieve_one_entity(Patient(id = "75d569fd-0142-40e0-9f6a-8dd3f2154afc"),
                                          false,
                                          dbconn)
unit = PostgresORM.retrieve_one_entity(Unit(id = "0d1311c9-f950-4d5b-b601-ca163169d124"),
                                          false,
                                          dbconn)
stay = Stay(patient = patient, unit = unit,
            inDate = Date("2021-01-01"),
            inTime = ZonedDateTime(DateTime("2021-01-01T08:00:00"),tz"Europe/Paris") )
PostgresORM.create_entity!(stay,dbconn)

analysis = Analysis(stay = stay, patient = patient,
                    requestDate = Date("2021-01-02"))
PostgresORM.create_entity!(analysis,dbconn)

TRAQUERUtil.closeDBConn(dbconn)


stay = PostgresORM.retrieve_one_entity(stay,false,dbconn)
PostgresORM.retrieve_one_entity(Analysis(stay = stay),false,dbconn)


timeZoneNoumea = tz"Pacific/Noumea"

zdt = ZonedDateTime(now(),timeZoneNoumea)
TimeZones.first_valid(now(),timeZoneNoumea) |> n -> Dates.Date(n)
TimeZones.

typeof(TimeZones.now())

Dates.day()

Dates.Date(now())


str = "abc"
last(str)

ZonedDateTime(Date("2019-01-02"),tz"Europe/Paris")


_df = DataFrames.DataFrame(x = [10,2,2,3], y = ["a","b","c","d"])

string.(_df.x, _df.y)

first(_df)
_df_grouped = groupby(_df,:x)
keys(keys(_df_grouped)[1])

join(_df_grouped[2].y,",")

for g in _df_grouped
   # r = first(g)
   # @info r.y
   @info join(string.(g.y,g.x),",")

end


for r in eachrow(_df_grouped[2])
   println(r.y)
end


@eval $(Symbol("APPUSER_TYPE"))

dummy_object = Appuser()
PostgresORM.get_orm(dummy_object).types_override[:allRoles]

module Toto
const toto = 4
const toto = 5

end  # module
Main.Toto.toto

PostgresORM.Controller.ModificationORM.get_schema_name() = "supervision"

"éee"[1]



TRAQUERUtil.time
passmissing(TRAQUERUtil.convertStringToZonedDateTime)(missing,"",TRAQUERUtil.getTimeZone())

dbconn = TRAQUERUtil.openDBConn()
PatientCtrl.createCryptedPatientName(
    "MARIE-ANTOINETTE",
    "TOKOTOKO",
    getDefaultEncryptionStr(),
    dbconn)


result = [1,2] |>
    n -> filter( x -> x > 1, n) |>
    n -> begin
        if isempty(n)
        else
            return 999 # this exits the chain of pipes
        end
    end |>
    n -> return n + 1


a = [11,12,13,14,15,16]
for (i, n) in enumerate(a)
    @info n isodd(n)
    if isodd(n)
        filter!(x -> !isodd(x), a)
    end
end

a = [11,12,13,14,15,16]
# filter!(x -> !isodd(x), a)
for (i,n) in enumerate(a)
    @info n isodd(n) "index[$i]"
    if isodd(n)
        filter!(x -> !isodd(x), a)
    end
end


dbconn = TRAQUERUtil.openDBConn()

outbreak = PostgresORM.retrieve_one_entity(
    Outbreak(id = "aed16920-c13d-418e-b54c-cee7ff9d7fd4"), false, dbconn)

OutbreakCtrl.generateDefaultOutbreakUnitAssos(
    outbreak,
    false , # simulate::Bool,
    dbconn
    ;cleanExisting = true
)

TRAQUERUtil.closeDBConn(dbconn)


dbconn = TRAQUERUtil.openDBConn()
ist = PostgresORM.retrieve_one_entity(
    InfectiousStatus(id = "6d647032-dd98-47cd-b3f7-8f2ba2ff9c57"), false, dbconn)
outbreak1 = PostgresORM.retrieve_one_entity(
    Outbreak(name = "test vincent"),false,dbconn
)
outbreak1 = Outbreak(id = "f110e0a6-7b84-4de5-b1f2-c729ab917572")
outbreak2 = PostgresORM.retrieve_one_entity(
    Outbreak(name = "test 2"),false,dbconn
)


ist.outbreakInfectiousStatusAssoes = [
    OutbreakInfectiousStatusAsso(outbreak = outbreak1),
    # OutbreakInfectiousStatusAsso(outbreak = outbreak2)
]

PostgresORM.update_vector_property!(ist, :outbreakInfectiousStatusAssoes, dbconn)
TRAQUERUtil.closeDBConn(dbconn)


dfStays = CSV.read(
    "/home/traquer/DATA/pending/dxcare-3mois.csv",
    DataFrame
    ;delim = ';'
)


dfStaysGroupedByNIP = groupby(dfStays,:NIP)
supertype(typeof(dfStaysGroupedByNIP[1]))

length(dfStaysGroupedByNIP)

dfAnalyses = CSV.read(
    "/home/traquer/DATA/pending/inlog-3mois.csv",
    DataFrame
    ;delim = ';'
)


using dates
Time("23:59:59")

Time(lpad("359",4,'0'),DateFormat("HHMM"))

dfAnalyses.ANA_CODE |> unique
ANA_CODE

dfAnalyses |>
n -> filter(x -> x.ANA_CODE == "GXEPC",n) |>
n -> unique(n.VALEUR_RESULTAT)
n -> filter(x -> !ismissing(x.VALEUR_RESULTAT) && x.VALEUR_RESULTAT ∈ ["PIMP", "PVIM", "PNDM", "PKPC", "POXA"], n) |>
first

dfAnalyses |>
n -> filter(x -> x.ANA_CODE == "PREPC",n) |>
n -> unique(n.VALEUR_RESULTAT)

# Rows for patients with culture of EPC positive
dfAnalyses |>
n -> filter(x -> x.ANA_CODE == "PREPC",n) |>
n -> filter(x -> !ismissing(x.VALEUR_RESULTAT) && x.VALEUR_RESULTAT == "P",n) |>
n -> unique(n.NIP_PATIENT) |>
n -> filter(x -> x.NIP_PATIENT ∈ n,dfAnalyses)


dfAnalyses |>
n -> filter(x -> x.ANA_CODE == "PREPC",n) |>
n -> unique(n.VALEUR_RESULTAT)

_tz = TRAQUERUtil.getTimeZone()
passmissing(TRAQUERUtil.convertStringToZonedDateTime)(
    passmissing(string)(missing),
    "00:00",
    _tz
)


String7("de") |> String |> typeof

df = DataFrame(col1 = ["00037839", "0000456", "0000789", "xx899"])

df.col1 = replace.(df.col1, r"^0+" => s"")

println(df)


df = DataFrame(a = [1,2], b = [3,4])
CSV.write("/home/traquer/CODE/TRAQUER.jl/tmp/df.csv", df; delim = ";")


res = @showprogress pmap(1:5) do i
    if iseven(i)
        DataFrame(col1=i,col2=1*3)
    else
        DataFrame()
    end
end |> n -> vcat(n...)

res[!, "error"] = Vector{Union{Missing, String}}(fill(missing, size(res, 1)))

res[1,:error] = "dde"

onerow = deepcopy(first(res))
onerow.col1 = 1000
hcat(onerow,)
onerow.err = ""

push!(res,onerow)

toto = DataFrame()
push!(toto,onerow)


df = DataFrame(col1 = [100,200])
df.lineNumInSrcFile = 2:nrow(df)+1

for (i,r) in enumerate(eachrow(df))
    @info i
    @info r
end


function readFirstNLinesOfFile(filePath::String, n::Integer)

end

readFirstNLinesOfFile("",9)


fill(missing, 2)

CSV.File("test/TRAQUERUtil/assets/testReadFirstLines.csv")
