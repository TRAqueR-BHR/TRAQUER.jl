
data_type = Model.AnalysisRequest
PostgresORM.get_orm(x::Model.AnalysisRequest) = return(ORM.AnalysisRequestORM)
get_schema_name() = "public"
get_table_name() = "analysis_request"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :creator => "creator_id", 
  :lastEditor => "last_editor_id", 
  :unit => "unit_id", 
  :id => "id", 
  :requestType => "request_type", 
  :creationTime => "creation_time", 
  :lastUpdateTime => "last_update_time", 
  :statusType => "status_type", 
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
  :creator => Model.Appuser, 
  :lastEditor => Model.Appuser, 
  :unit => Model.Unit, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
