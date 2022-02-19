const types_override = Dict(
  :creator => Model.Appuser,
  :lastEditor => Model.Appuser,
  :lastEditorAppuserRoleAssoes => Vector{Model.AppuserRoleAsso},
  :appuserAppuserRoleAssoes => Vector{Model.AppuserRoleAsso},
  :creatorAppuserRoleAssoes => Vector{Model.AppuserRoleAsso},
  :creatorAppusers => Vector{Model.Appuser},
  :lastEditorAppusers => Vector{Model.Appuser},
  :allRoles => Vector{Model.Role},
)

# Specify whether we want to track the changes to the objects of this class
get_track_changes() = true # Uncomment and modify if needed
get_creator_property() = :creator # Uncomment and modify if needed
get_editor_property() = :lastEditor # Uncomment and modify if needed
get_creation_time_property() = :creationTime # Uncomment and modify if needed
get_update_time_property() = :updateTime # Uncomment and modify if needed
