
data_type = Model.Role
PostgresORM.get_orm(x::Model.Role) = return(ORM.RoleORM)
get_schema_name() = "usersch"
get_table_name() = "role"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :id => "id", 
  :composed => "composed", 
  :codeName => "code_name", 
  :restrictedToAppuserType => "restricted_to_appuser_type", 
)


# Declare which properties are used to uniquely identify an object
get_id_props() = return [:id,]

# Associate the onetomany properties to the corresponding manytoone peroperties in the other classes 
get_onetomany_counterparts() = return onetomany_counterparts
const onetomany_counterparts = Dict(

  :appuserRoleAssoes => (
    data_type = Model.AppuserRoleAsso, # The struct where the associated manytoone property is
    property = :role, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :handlerRoleRoleRoleAssoes => (
    data_type = Model.RoleRoleAsso, # The struct where the associated manytoone property is
    property = :handlerRole, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :handledRoleRoleRoleAssoes => (
    data_type = Model.RoleRoleAsso, # The struct where the associated manytoone property is
    property = :handledRole, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

)

# Override the abstract types 
get_types_override() = return types_override
const types_override = Dict(
  :appuserRoleAssoes => Vector{Model.AppuserRoleAsso}, 
  :handlerRoleRoleRoleAssoes => Vector{Model.RoleRoleAsso}, 
  :handledRoleRoleRoleAssoes => Vector{Model.RoleRoleAsso}, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
