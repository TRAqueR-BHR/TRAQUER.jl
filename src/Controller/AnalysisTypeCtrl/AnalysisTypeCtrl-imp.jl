function AnalysisTypeCtrl.createAnalysisTypeIfNotExist(codeName::String,
                                                       name::String,
                                                       dbconn::LibPQ.Connection)

      analysisType = PostgresORM.retrieve_one_entity(AnalysisType(codeName = codeName),
                                                     false, # complex prop
                                                     dbconn)
      if !ismissing(analysisType)
            return analysisType
      end

      # Create the missing AnalysisType
      analysisType = AnalysisType(codeName = codeName, name = name)
      PostgresORM.create_entity!(analysisType,dbconn)
      return analysisType

end
