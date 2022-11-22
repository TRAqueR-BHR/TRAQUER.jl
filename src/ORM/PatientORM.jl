
data_type = Model.Patient
PostgresORM.get_orm(x::Model.Patient) = return(ORM.PatientORM)
get_schema_name() = "public"
get_table_name() = "patient"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :currentUnit => "current_unit_id", 
  :patientNameCrypt => ["name_crypt_id", "lastname_first_letter"], 
  :patientRefCrypt => ["ref_crypt_id", "ref_one_char"], 
  :patientBirthdateCrypt => ["birthdate_crypt_id", "birth_year"], 
  :id => "id", 
  :isHospitalized => "is_hospitalized", 
  :traquerRef => "traquer_ref", 
  :gender => "gender", 
)


# Declare which properties are used to uniquely identify an object
get_id_props() = return [:id,]

# Associate the onetomany properties to the corresponding manytoone peroperties in the other classes 
get_onetomany_counterparts() = return onetomany_counterparts
const onetomany_counterparts = Dict(

  :analysisResults => (
    data_type = Model.AnalysisResult, # The struct where the associated manytoone property is
    property = :patient, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :contactContactExposures => (
    data_type = Model.ContactExposure, # The struct where the associated manytoone property is
    property = :contact, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :carrierContactExposures => (
    data_type = Model.ContactExposure, # The struct where the associated manytoone property is
    property = :carrier, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :infectiousStatuses => (
    data_type = Model.InfectiousStatus, # The struct where the associated manytoone property is
    property = :patient, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :staies => (
    data_type = Model.Stay, # The struct where the associated manytoone property is
    property = :patient, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

)

# Override the abstract types 
get_types_override() = return types_override
const types_override = Dict(
  :currentUnit => Model.Unit, 
  :patientNameCrypt => Model.PatientNameCrypt, 
  :patientRefCrypt => Model.PatientRefCrypt, 
  :patientBirthdateCrypt => Model.PatientBirthdateCrypt, 
  :analysisResults => Vector{Model.AnalysisResult}, 
  :contactContactExposures => Vector{Model.ContactExposure}, 
  :carrierContactExposures => Vector{Model.ContactExposure}, 
  :infectiousStatuses => Vector{Model.InfectiousStatus}, 
  :staies => Vector{Model.Stay}, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
