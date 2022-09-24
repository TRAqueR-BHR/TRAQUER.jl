
data_type = Model.Unit
PostgresORM.get_orm(x::Model.Unit) = return(ORM.UnitORM)
get_schema_name() = "public"
get_table_name() = "unit"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :id => "id", 
  :name => "name", 
  :codeName => "code_name", 
)


# Declare which properties are used to uniquely identify an object
get_id_props() = return [:id,]

# Associate the onetomany properties to the corresponding manytoone peroperties in the other classes 
get_onetomany_counterparts() = return onetomany_counterparts
const onetomany_counterparts = Dict(

  :outbreakConfigUnitAssoes => (
    data_type = Model.OutbreakConfigUnitAsso, # The struct where the associated manytoone property is
    property = :unit, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :staies => (
    data_type = Model.Stay, # The struct where the associated manytoone property is
    property = :unit, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :contactExposures => (
    data_type = Model.ContactExposure, # The struct where the associated manytoone property is
    property = :unit, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :patients => (
    data_type = Model.Patient, # The struct where the associated manytoone property is
    property = :currentUnit, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :analysisRequests => (
    data_type = Model.AnalysisRequest, # The struct where the associated manytoone property is
    property = :unit, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

)

# Override the abstract types 
get_types_override() = return types_override
const types_override = Dict(
  :outbreakConfigUnitAssoes => Vector{Model.OutbreakConfigUnitAsso}, 
  :staies => Vector{Model.Stay}, 
  :contactExposures => Vector{Model.ContactExposure}, 
  :patients => Vector{Model.Patient}, 
  :analysisRequests => Vector{Model.AnalysisRequest}, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
