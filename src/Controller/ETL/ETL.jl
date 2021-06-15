using Revise
using TRAQUER
using TRAQUER.Model
using TRAQUER.TRAQUERUtils
using PostgresqlDAO
using CSV
using DataFrames
using PostgresqlDAO
using Dates
using TimeZones
using XLSX

function importStays(dxcaredf::DataFrame, timeZone::TimeZones.VariableTimeZone)



    dbconn = TRAQUERUtils.opendbconn()


    lineCounter = 0

    for r in eachrow(dxcaredf)

       lineCounter += 1
       # Check if patient already exists in the db, if not create it
       dateBirth = Date(r.RANDOM_DATE_NAISSANCE,DateFormat("d/m/y"))
       @info dateBirth

       patient = PostgresqlDAO.Controller.retrieve_one_entity(Patient(firstname
       = r.RANDOM_PRENOM, surname = r.RANDOM_NOM, birthdate = dateBirth),false,
       dbconn)


       if ismissing(patient)
          patient = Patient(birthdate = dateBirth,firstname = r.RANDOM_PRENOM,
                            surname = r.RANDOM_NOM)
          PostgresqlDAO.create_entity!(patient,dbconn)
       end



       # Check if FctUnit exists, if not create it
       fct_unit =
          PostgresqlDAO.Controller.retrieve_one_entity(
             FctUnit(codeName = r.CODE_UF_RESP,),false,dbconn)
       @info fct_unit


       if ismissing(fct_unit)
          fct_unit = FctUnit(codeName = r.CODE_UF_RESP, name = r.NOM_UF_RESP)
          PostgresqlDAO.create_entity!(fct_unit,dbconn)
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
          TRAQUERUtils.convertStringToZonedDateTime(dateEntree,heureEntree,
                                                    timeZone)

    @info dateSortie
    @info "lineCounter[$lineCounter]"

       sortieMouvement =
          TRAQUERUtils.convertStringToZonedDateTime(dateSortie,heureSortie,
                                                    timeZone)



       fct_unit_stay =
       PostgresqlDAO.Controller.retrieve_one_entity(
          FctUnitStay(inDateTime = entreeMouvement,
                      outDateTime = sortieMouvement,
                      patient = patient,fctUnit = fct_unit),false,dbconn)

       @info fct_unit_stay


       if ismissing(fct_unit_stay)
          fct_unit_stay =
             FctUnitStay(inDateTime = entreeMouvement,
                         outDateTime = sortieMouvement,
                         patient = patient,fctUnit = fct_unit)
          PostgresqlDAO.create_entity!(fct_unit_stay,dbconn)
       end



    end #end of loop
    TRAQUERUtils.closedbconn(dbconn)

end


function importAnalysis(inlog::DataFrame,
                        timeZone::TimeZones.VariableTimeZone)



      dbconn = TRAQUERUtils.opendbconn()

      lineCounter = 0

      for r in eachrow(inlog)
         lineCounter += 1

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

         #query name and date
         query1 = "select * from patient where r.RANDOM_NOM equals
                  patient.firstname and r.RANDOM_PRENOM equals patient.surname
                  and r.RANDOM_DATE_NAISSANCE equals patient.birthdate"

         query2 = "select * from fct_unit_stay where \$1 between
                  fct_unit_stay.in_date_time
                  and fct_unit_stay.out_date_time"

         args = [dateHeureDemande]

         PostgresqlDAO.Controller.execute_query_and_handle_result(query1,Patient, args,
         false,dbconn)

         PostgresqlDAO.Controller.execute_query_and_handle_result(query2,Patient, args,
         false,dbconn)



         lab_analysis =
         PostgresqlDAO.Controller.retrieve_one_entity(
            LabAnalysis(requestDate = dateHeureDemande, bmr = r.BMR,
                        sampleType = r.NATURE_CODE,result = strBilan,
                        analysisType = r.Libelle_nature_prelevement)
                        ,false,dbconn)

   @info "lineCounter[$lineCounter]"



         if ismissing(lab_analysis)
            lab_analysis =
               LabAnalysis(requestDate = dateHeureDemande,bmr = r.BMR,
                           sampleType = r.NATURE_CODE,result = strBilan,
                           analysisType = r.Libelle_nature_prelevement)
            PostgresqlDAO.create_entity!(lab_analysis,dbconn)
         end



   end #end of let
   TRAQUERUtils.closedbconn(dbconn)
      end #end of loop
