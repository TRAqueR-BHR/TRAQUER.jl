
data_type = Model.Analysis
PostgresORM.get_orm(x::Model.Analysis) = return(ORM.AnalysisORM)
get_schema_name() = "public"
get_table_name() = "analysis"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :patient => "patient_id", 
  :stay => ["stay_id", "stay_in_date"], 
  :analysisRefCrypt => ["ref_crypt_id", "ref_one_char"], 
  :analysisType => "analysis_type_id", 
  :id => "id", 
  :requestDateTime => "request_date_time", 
  :sampleType => "sample_type", 
  :resultValue => "result_value", 
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
  :patient => Model.Patient, 
  :stay => Model.Stay, 
  :analysisRefCrypt => Model.AnalysisRefCrypt, 
  :analysisType => Model.AnalysisType, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
