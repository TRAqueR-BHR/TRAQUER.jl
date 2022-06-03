using Pkg
Pkg.activate(".")

using Revise
using TRAQUER
using TRAQUER.Model
using TRAQUER.TRAQUERUtils
using PostgresORM
using CSV
using DataFrames
using PostgresORM
using Dates
using TimeZones
using XLSX


dxcare = CSV.read("csv/mouvements DXCARE 202009-202010 avril 2021.csv", DataFrame)

#dxcare.RANDOM_DATE_NAISSANCE = dxcare(Patient.RANDOM_DATE_NAISSANCE,
#"dd-mm-yyyy")
#typeof(dxcare.RANDOM_DATE_NAISSANCE)

let

dbconn = TRAQUERUtils.opendbconn()


lineCounter = 0

for r in eachrow(dxcare)

   lineCounter += 1
   # Check if patient already exists in the db, if not create it
   dateBirth = Date(r.RANDOM_DATE_NAISSANCE,DateFormat("d/m/y"))
   @info dateBirth

   patient = PostgresORM.Controller.retrieve_one_entity(Patient(firstname
   = r.RANDOM_PRENOM, surname = r.RANDOM_NOM, birthdate = dateBirth),false,
   dbconn)


   if ismissing(patient)
      patient = Patient(birthdate = dateBirth,firstname = r.RANDOM_PRENOM,
                        surname = r.RANDOM_NOM)
      PostgresORM.create_entity!(patient,dbconn)
   end



   # Check if FctUnit exists, if not create it
   fct_unit =
      PostgresORM.Controller.retrieve_one_entity(
         FctUnit(codeName = r.CODE_UF_RESP,),false,dbconn)
   @info fct_unit


   if ismissing(fct_unit)
      fct_unit = FctUnit(codeName = r.CODE_UF_RESP, name = r.NOM_UF_RESP)
      PostgresORM.create_entity!(fct_unit,dbconn)
   end



   # Create the FctUnitStay


   if ismissing(r.DATE_SORTIE_MVT)
      continue
   end
   if ismissing(r.HEURE_ENT_MVT)
      continue
   end
   if ismissing(r.DATE_SORTIE_MVT)
      continue
   end
   if ismissing(r.HEURE_SOR_MVT)
      continue
   end

   dateEntree = string(r.DATE_SORTIE_MVT)
   heureEntree =string(r.HEURE_ENT_MVT)
   dateSortie = string(r.DATE_SORTIE_MVT)
   heureSortie =string(r.HEURE_SOR_MVT)



   entreeMouvement =
      TRAQUERUtils.convertStringToZonedDateTime(dateEntree,heureEntree,timeZone)

@info dateSortie
@info "lineCounter[$lineCounter]"

   sortieMouvement =
      TRAQUERUtils.convertStringToZonedDateTime(dateSortie,heureSortie,timeZone)



   fct_unit_stay =
   PostgresORM.Controller.retrieve_one_entity(
      FctUnitStay(inTime = entreeMouvement,outTime = sortieMouvement,
      patient = patient,fctUnit = fct_unit),false,dbconn)

   @info fct_unit_stay


   if ismissing(fct_unit_stay)
      fct_unit_stay =
         FctUnitStay(inTime = entreeMouvement,outTime = sortieMouvement,
                     patient = patient,fctUnit = fct_unit)
      PostgresORM.create_entity!(fct_unit_stay,dbconn)
   end



end
TRAQUERUtils.closedbconn(dbconn)
end


#--------------------------------------------



inlog = DataFrame(XLSX.readtable("csv/mouvements INLOG 202009-202010 avril 2021 Short.xlsx"
,"Sheet1")...)



let


   dbconn = TRAQUERUtils.opendbconn()

   lineCounter = 0

   for r in eachrow(inlog)
      lineCounter += 1
      timeZone = tz"Europe/Paris"

   # Insert request date
      if ismissing(r.DATE_DEMANDE)
         continue
      end


      dateDemande = string(r.DATE_DEMANDE)
      heureDemande = string(r.HEURE_DEMANDE)
      strBilan = string(r.BILAN)


      dateHeureDemande =
      TRAQUERUtils.convertStringToZonedDateTime(dateDemande,heureDemande,
      timeZone)

      prenomPatient = R.RANDOM_PRENOM
      nomPatient = R.RAMDOM_NOM
      datePatient = R.RANDOM_DATE_NAISSANCE

      query_patient = "select * from patient where  patient.firstname = \$1
               and patient.surname = \$2 and patient.birthdate = \$3"

      args = [prenomPatient,nomPatient,datePatient]

      result_query_patient =
         PostgresORM.Controller.execute_query_and_handle_result(
                                 query,Patient, args,
                                 false,dbconn)

      if isempty(result_query_patient)


      query_fct_unit_stay = "select * from fct_unit_stay s where \$1 between(
               s.in_time and s.out_time) and s.patient_id = \$2 "

      args = [dateHeureDemande,patient.id]


      result_query_fct_unit_sta =
         PostgresORM.Controller.execute_query_and_handle_result(
                                 query,Patient, args,
                                 false,dbconn)



      lab_analysis =
      PostgresORM.Controller.retrieve_one_entity(
         LabAnalysis(requestDate = dateHeureDemande, bmr = r.BMR,
                     sampleType = r.NATURE_CODE,result = strBilan,
                     analysisType = r.Libelle_nature_prelevement,
                     resultValue =r.VALEUR_RESULTAT)
                     ,false,dbconn)


#EPC

      query_déspistage_moléculaire = "select * from lab_analysis
                                      where result = 'GXEPCC'"

      result_query_déspistage_moléculaire = PostgresORM.Controller
                                            .execute_query_and_handle_result(
                                                                        query,
                                                                  false,dbconn)


      query_valeur_resultat = "select * from lab_analysis where resultValue =
                              'A' or 'NEPC'"

      result_query_valeur_resultat



@info "lineCounter[$lineCounter]"



      if ismissing(lab_analysis)
         lab_analysis =
            LabAnalysis(requestDate = dateHeureDemande,bmr = r.BMR,
                        sampleType = r.NATURE_CODE,result = strBilan,
                        analysisType = r.Libelle_nature_prelevement)
         PostgresORM.create_entity!(lab_analysis,dbconn)
      end



end #end of let
TRAQUERUtils.closedbconn(dbconn)
   end #end of loop
