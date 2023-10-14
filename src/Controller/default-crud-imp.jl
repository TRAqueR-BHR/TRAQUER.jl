
"Récupération d'un objet de type IEntity sur la base d'un filtre"
function Controller.retrieveOneEntity(filterObject::T) where T <: PostgresORM.IEntity
    Controller.retrieveOneEntity(filterObject
                     ;retrieveComplexProps = true,
                      includeVectorProps = false)
end

function Controller.retrieveOneEntity(filterObject::T,
                           retrieveComplexProps::Bool,
                           includeVectorProps::Bool) where T <: PostgresORM.IEntity
    Controller.retrieveOneEntity(filterObject
                     ;retrieveComplexProps = retrieveComplexProps,
                      includeVectorProps = includeVectorProps)
end

function Controller.retrieveOneEntity(filterObject::T
                          ;retrieveComplexProps::Bool = true,
                           includeVectorProps::Bool = false) where T <: PostgresORM.IEntity
      results = Controller.retrieveEntities(filterObject
                                ;includeVectorProps = includeVectorProps)
      if length(results) > 1
          error("Trop de résultats")
      end
      if length(results) == 0
          return missing
      end
      result = results[1]
      return result
end

"Récupération des objets de type IEntity sur la base d'un filtre"
function Controller.retrieveEntities(filterObject::T
                        ;retrieveComplexProps::Bool = true,
                         includeVectorProps::Bool = false) where T <: PostgresORM.IEntity
    dbconn = openDBConn()
    try
         result = PostgresORM.retrieve_entity(filterObject,
                                              retrieveComplexProps, # retrieve_complex_props
                                              dbconn)
         # Retrieve other attributes
         if includeVectorProps
             Controller.enrichWithVectorProps!.(result, dbconn)
         end
         return result
    catch e
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end
end

"Enrichit un objet IEntity avec ses attributs de type Vector"
function Controller.enrichWithVectorProps!(object::T,
                                dbconn::LibPQ.Connection) where T <: PostgresORM.IEntity
   # À surcharger si besoin
end

"Action qui précède la mise à jour d'un objet IEntity dans la base de données"
function Controller.preUpdate!(object::T) where T <: PostgresORM.IEntity end

"Action qui précède l'ajout d'un objet IEntity dans la base de données"
function Controller.prePersist!(object::T) where T <: PostgresORM.IEntity end

"Action qui succède à la mise à jour d'un objet IEntity dans la base de données"
function Controller.postUpdate!(object::T) where T <: PostgresORM.IEntity end

"Action qui succède à l'ajout d'un objet IEntity dans la base de données"
function Controller.postPersist!(object::T) where T <: PostgresORM.IEntity end

"Overwrite this function if needed"
function Controller.updateVectorProps!(
    object::T,
    dbconn::LibPQ.Connection
    ;editor::Union{Missing, Appuser} = missing
) where T <: PostgresORM.IEntity
   @info "Default Controller.updateVectorProps!: DO NOTHING"
end

"Ajoute un objet IEntity dans la base de données"
function Controller.persist!(newObject::T
                 ;creator::Union{Missing, Appuser} = missing) where T <: PostgresORM.IEntity

    Controller.prePersist!(newObject)
    # @info "default persist!"
    dbconn = openDBConnAndBeginTransaction()
    try
       PostgresORM.create_entity!(newObject,
                                  dbconn;
                                  creator = creator)
       # Il n y a pas de risque à faire la mise à jour des attributs de type liste
       #   vu que l'objet n'existe pas encore
       Controller.updateVectorProps!(newObject, dbconn
                         ;editor = creator)
       Controller.postPersist!(newObject)
       commitDBTransaction(dbconn)
       return newObject
   catch e
      rollbackDBTransaction(dbconn)
      rethrow(e)
   finally
      closeDBConn(dbconn)
   end

end


"Met à jour un objet IEntity dans la base de données"
function Controller.update!(object::T
                ;updateVectorProps::Union{Missing, Bool} = false,
                 editor::Union{Missing, Appuser} = missing) where T <: PostgresORM.IEntity

@info "DEBUG1"
    Controller.preUpdate!(object)
@info "DEBUG2"
    dbconn = openDBConnAndBeginTransaction()

    try
@info "DEBUG3"
        # Update the entity itself
        PostgresORM.update_entity!(object,
                                   dbconn
                                  ;editor = editor)
@info "DEBUG4"
        # Update the associations
        if updateVectorProps
            Controller.updateVectorProps!(
                object,
                dbconn
                ;editor = editor
            )
            @info "DEBUG5!!"
        end

        Controller.postUpdate!(object)
        commitDBTransaction(dbconn)
        return object
    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end
end
