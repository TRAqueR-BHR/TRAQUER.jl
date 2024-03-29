
data_type = Model.TaskWaitingForUserExecution
PostgresORM.get_orm(x::Model.TaskWaitingForUserExecution) = return(ORM.TaskWaitingForUserExecutionORM)
get_schema_name() = "misc"
get_table_name() = "task_waiting_for_user_execution"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :id => "id", 
  :startTime => "start_time", 
  :name => "name", 
  :errorMsg => "error_msg", 
  :creationTime => "creation_time", 
  :success => "success", 
  :endOrErrorTime => "end_or_error_time", 
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

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
