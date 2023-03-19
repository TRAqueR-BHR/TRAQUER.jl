# Associate the onetomany properties to the corresponding manytoone peroperties in the other classes
get_onetomany_counterparts() = return onetomany_counterparts_overwrite
const onetomany_counterparts_overwrite = Dict(

  :outbreakInfectiousStatusAssoes => (
    data_type = Model.OutbreakInfectiousStatusAsso, # The struct where the associated manytoone property is
    property = :infectiousStatus, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.delete), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned

  :eventRequiringAttentions => (
    data_type = Model.EventRequiringAttention, # The struct where the associated manytoone property is
    property = :infectiousStatus, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned

)
