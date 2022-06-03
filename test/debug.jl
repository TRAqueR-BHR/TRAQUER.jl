using Pkg
Pkg.activate(".")

using Revise
using TRAQUER
using TRAQUER.Model
using TRAQUER.TRAQUERUtils
using TRAQUER.Controller
using PostgresORM
using CSV
using DataFrames
using TimeZones
using Dates
using Test

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
   TRAQUERUtils.opendbconn()

PostgresORM.Controller.create_entity!(patient1, dbconn)
PostgresORM.Controller.update_entity!(patient2, dbconn)

TRAQUERUtils.closedbconn(dbconn)

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
dbconn = TRAQUERUtils.opendbconn()

PostgresORM.Controller.execute_query_and_handle_result(query,Patient,args,false,dbconn)


toto = XLSX.readxlsx("csv/Untitled 1.xlsx")
Tables typeof(toto["Sheet1"])
names(df)
df = DataFrame(XLSX.readtable("csv/Untitled 1.xlsx", "Sheet1")...)

tata = (XLSX.readtable("csv/Untitled 1.xlsx", "Sheet1")...)


dateDemande = string("05/10/1999")
heureDemande = string("000")
timeZoned = tz"Europe/Paris"

dateHeureDemandes =
TRAQUERUtils.convertStringToZonedDateTime(dateDemande,heureDemande,
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
passmissing(TRAQUERUtil.convertStringToZonedDateTime)(missing,"",TRAQUERUtil.getTimezone())

dbconn = TRAQUERUtil.openDBConn()
PatientCtrl.createCryptedPatientName(
    "MARIE-ANTOINETTE",
    "TOKOTOKO",
    getDefaultEncryptionStr(),
    dbconn)


    intersect
