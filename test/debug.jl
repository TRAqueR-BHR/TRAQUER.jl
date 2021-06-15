using Pkg
Pkg.activate(".")

using Revise
using TRAQUER
using TRAQUER.Model
using TRAQUER.TRAQUERUtils
using TRAQUER.Controller
using PostgresqlDAO
using CSV
using DataFrames
using TimeZones
using Dates
using Test



@test 2==2



TRAQUER.greet()
TRAQUER.Model.Patient()


patient3 = TRAQUER.Model.Patient(firstname="Laure",)


patient2.surname="Provert"

patient3.gender=TRAQUER.Enums.Gender.female
TRAQUER.DAO.FctUnitDAO.get_table_name()

PostgresqlDAO.Controller.create_entity!(patient, dbconn)
using PostgresqlDAO
using LibPQ


dbconn=
   TRAQUERUtils.opendbconn()

PostgresqlDAO.Controller.create_entity!(patient1, dbconn)
PostgresqlDAO.Controller.update_entity!(patient2, dbconn)

TRAQUERUtils.closedbconn(dbconn)

dxcare = CSV.read("csv/mouvements DXCARE 202009-202010.csv", DataFrame)

#outdir = "/home/medi/Documents/Code/TRAQUER.jl/misc/reverse-engineering/out"
#PostgresqlDAO.Tool.generate_julia_code(dbconn, outdir ;module_name_for_all_schemas = "Model")

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

PostgresqlDAO.Controller.execute_query_and_handle_result(query,Patient,args,false,dbconn)


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


query = "select * from fct_unit_stay where between fct_unit_stay.in_date_time
         and fct_unit_stay.out_date_time =\$1"
args = [dateHeureDemande]

PostgresqlDAO.Controller.execute_query_and_handle_result(query,Patient, args,
                                                         false,dbconn)
