
data_type = Model.ContactExposure
PostgresORM.get_orm(x::Model.ContactExposure) = return(ORM.ContactExposureORM)
get_schema_name() = "public"
get_table_name() = "contact_exposure"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :unit => "unit_id", 
  :contact => "contact_id", 
  :carrier => "carrier_id", 
  :outbreak => "outbreak_id", 
  :id => "id", 
  :startTime => "start_time", 
  :endTime => "end_time", 
)


# Declare which properties are used to uniquely identify an object
get_id_props() = return [:id,]

# Associate the onetomany properties to the corresponding manytoone peroperties in the other classes 
get_onetomany_counterparts() = return onetomany_counterparts
const onetomany_counterparts = Dict(

  :infectiousStatuses => (
    data_type = Model.InfectiousStatus, # The struct where the associated manytoone property is
    property = :contactExposure, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

)

# Override the abstract types 
get_types_override() = return types_override
const types_override = Dict(
  :unit => Model.Unit, 
  :contact => Model.Patient, 
  :carrier => Model.Patient, 
  :outbreak => Model.Outbreak, 
  :infectiousStatuses => Vector{Model.InfectiousStatus}, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
