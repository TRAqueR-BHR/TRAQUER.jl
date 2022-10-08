
data_type = Model.Appuser
PostgresORM.get_orm(x::Model.Appuser) = return(ORM.AppuserORM)
get_schema_name() = "usersch"
get_table_name() = "appuser"


# Declare the mapping between the properties and the database columns
get_columns_selection_and_mapping() = return columns_selection_and_mapping
const columns_selection_and_mapping = Dict(
  :creator => "creator_id", 
  :lastEditor => "last_editor_id", 
  :id => "id", 
  :login => "login", 
  :email => "email", 
  :firstname => "firstname", 
  :appuserType => "appuser_type", 
  :languageCode => "language_code", 
  :password => "password", 
  :creationTime => "creation_time", 
  :avatarId => "avatar_id", 
  :lastname => "lastname", 
  :preferences => "preferences", 
  :deactivated => "deactivated", 
  :updateTime => "update_time", 
)


# Declare which properties are used to uniquely identify an object
get_id_props() = return [:id,]

# Associate the onetomany properties to the corresponding manytoone peroperties in the other classes 
get_onetomany_counterparts() = return onetomany_counterparts
const onetomany_counterparts = Dict(

  :outbreakConfigUnitAssoes => (
    data_type = Model.OutbreakConfigUnitAsso, # The struct where the associated manytoone property is
    property = :creator, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :outbreaks => (
    data_type = Model.Outbreak, # The struct where the associated manytoone property is
    property = :creator, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :eventRequiringAttentions => (
    data_type = Model.EventRequiringAttention, # The struct where the associated manytoone property is
    property = :responseUser, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :creatorAnalysisRequests => (
    data_type = Model.AnalysisRequest, # The struct where the associated manytoone property is
    property = :creator, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :lastEditorAnalysisRequests => (
    data_type = Model.AnalysisRequest, # The struct where the associated manytoone property is
    property = :lastEditor, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :lastEditorAppuserRoleAssoes => (
    data_type = Model.AppuserRoleAsso, # The struct where the associated manytoone property is
    property = :lastEditor, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :appuserAppuserRoleAssoes => (
    data_type = Model.AppuserRoleAsso, # The struct where the associated manytoone property is
    property = :appuser, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :creatorAppuserRoleAssoes => (
    data_type = Model.AppuserRoleAsso, # The struct where the associated manytoone property is
    property = :creator, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :creatorAppusers => (
    data_type = Model.Appuser, # The struct where the associated manytoone property is
    property = :creator, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

  :lastEditorAppusers => (
    data_type = Model.Appuser, # The struct where the associated manytoone property is
    property = :lastEditor, # The name of the associated manytoone property
    action_on_remove = PostgresORM.CRUDType.update), # Change this to 'PostgresORM.CRUDType.delete' if the object doesn't make sense when orphaned 

)

# Override the abstract types 
get_types_override() = return types_override
const types_override = Dict(
  :creator => Model.Appuser, 
  :lastEditor => Model.Appuser, 
  :outbreakConfigUnitAssoes => Vector{Model.OutbreakConfigUnitAsso}, 
  :outbreaks => Vector{Model.Outbreak}, 
  :eventRequiringAttentions => Vector{Model.EventRequiringAttention}, 
  :creatorAnalysisRequests => Vector{Model.AnalysisRequest}, 
  :lastEditorAnalysisRequests => Vector{Model.AnalysisRequest}, 
  :lastEditorAppuserRoleAssoes => Vector{Model.AppuserRoleAsso}, 
  :appuserAppuserRoleAssoes => Vector{Model.AppuserRoleAsso}, 
  :creatorAppuserRoleAssoes => Vector{Model.AppuserRoleAsso}, 
  :creatorAppusers => Vector{Model.Appuser}, 
  :lastEditorAppusers => Vector{Model.Appuser}, 

)

# Specify whether we want to track the changes to the objects of this class 
# get_track_changes() = false # Uncomment and modify if needed 
# get_creator_property() = :a_property_symbol # Uncomment and modify if needed 
# get_editor_property() = :a_property_symbol # Uncomment and modify if needed 
# get_creation_time_property() = :a_property_symbol # Uncomment and modify if needed 
# get_update_time_property() = :a_property_symbol # Uncomment and modify if needed 
