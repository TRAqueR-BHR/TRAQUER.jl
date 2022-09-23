
data_type = Model.EventRequiringAttention
PostgresORM.get_orm(x::Model.EventRequiringAttention) = return(ORM.EventRequiringAttentionORM)
get_schema_name() = "public"
get_table_name() = "event_requiring_attention"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :responseUser => "response_user_id", 
  :infectiousStatus => "infectious_status_id", 
  :id => "id", 
  :responseTime => "response_time", 
  :responseComment => "response_comment", 
  :isPending => "is_pending", 
  :eventType => "event_type", 
  :refTime => "ref_time", 
  :responsesTypes => "responses_types", 
)


# Declare which properties are used to uniquely identify an object
get_id_props() = return [:id,]

# Associate the onetomany properties to the corresponding manytoone peroperties in the other classes 
get_onetomany_counterparts() = return onetomany_counterparts
const onetomany_counterparts = Dict(

)

# Override the abstract types 
get_types_override() = return types_override
const types_override = Dict(
  :responseUser => Model.Appuser, 
  :infectiousStatus => Model.InfectiousStatus, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
