
data_type = Model.Stay
PostgresORM.get_orm(x::Model.Stay) = return(ORM.StayORM)
get_schema_name() = "public"
get_table_name() = "stay"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :patient => "patient_id", 
  :unit => "unit_id", 
  :id => "id", 
  :inDate => "in_date", 
  :outTime => "out_time", 
  :sysCreationTime => "sys_creation_time", 
  :hospitalizationOutTime => "hospitalization_out_time", 
  :inTime => "in_time", 
  :hospitalizationInTime => "hospitalization_in_time", 
  :sysProcessingTime => "sys_processing_time", 
  :room => "room", 
)


# Declare which properties are used to uniquely identify an object
get_id_props() = return [:id,:inDate,]

# Associate the onetomany properties to the corresponding manytoone peroperties in the other classes 
get_onetomany_counterparts() = return onetomany_counterparts
const onetomany_counterparts = Dict(

  :analysisResults => (
    data_type = Model.AnalysisResult, # The struct where the associated manytoone property is
    property = :stay, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

)

# Override the abstract types 
get_types_override() = return types_override
const types_override = Dict(
  :patient => Model.Patient, 
  :unit => Model.Unit, 
  :analysisResults => Vector{Model.AnalysisResult}, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
