
data_type = Model.StayDataNeeded
PostgresORM.get_orm(x::Model.StayDataNeeded) = return(ORM.StayDataNeededORM)
get_schema_name() = "etl"
get_table_name() = "stay_data_needed"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :id => "id", 
  :periodOiEndTime => "period_oi_end_time", 
  :deactivationCondition => "deactivation_condition", 
  :periodOiStartTime => "period_oi_start_time", 
  :unitIds => "unit_ids", 
  :activationTime => "activation_time", 
  :patientIds => "patient_ids", 
  :deactivationTime => "deactivation_time", 
  :justification => "justification", 
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
