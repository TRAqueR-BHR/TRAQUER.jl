
data_type = Model.OutbreakUnitAsso
PostgresORM.get_orm(x::Model.OutbreakUnitAsso) = return(ORM.OutbreakUnitAssoORM)
get_schema_name() = "public"
get_table_name() = "outbreak_unit_asso"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :unit => "unit_id", 
  :outbreak => "outbreak_id", 
  :creator => "creator_id", 
  :id => "id", 
  :startTime => "start_time", 
  :endTime => "end_time", 
  :sameRoomOnly => "same_room_only", 
  :sameSectorOnly => "same_sector_only", 
  :isDefault => "is_default", 
  :comment => "comment", 
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
  :unit => Model.Unit, 
  :outbreak => Model.Outbreak, 
  :creator => Model.Appuser, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
