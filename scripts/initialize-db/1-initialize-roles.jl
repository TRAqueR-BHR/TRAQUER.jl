include("../prerequisite.jl")

using PostgresORM
using TRAQUER.Enum
using TRAQUER.Enum.AppuserType, TRAQUER.Enum.RoleCodeName

# ##################### #
# Create composed Roles #
# ##################### #
dbcon = TRAQUERUtil.openDBConn()

# doctor
role_doctor = Role(
    ;codeName = RoleCodeName.doctor,
    composed = true,
    restrictedToAppuserType = AppuserType.staff_member
)
AppuserCtrl.upsert!(role_doctor,dbcon)

# nurse
role_nurse = Role(
    ;codeName = RoleCodeName.nurse,
    composed = true,
    restrictedToAppuserType = AppuserType.staff_member
)
AppuserCtrl.upsert!(role_nurse,dbcon)

# caregiver
role_caregiver = Role(
    ;codeName = RoleCodeName.caregiver,
    composed = true,
    restrictedToAppuserType = AppuserType.staff_member
)
AppuserCtrl.upsert!(role_caregiver,dbcon)

# secretary
role_secretary = Role(
    ;codeName = RoleCodeName.secretary,
    composed = true,
    restrictedToAppuserType = AppuserType.staff_member
)
AppuserCtrl.upsert!(role_secretary,dbcon)

# biologist
role_biologist = Role(
    ;codeName = RoleCodeName.biologist,
    composed = true,
    restrictedToAppuserType = AppuserType.staff_member
)
AppuserCtrl.upsert!(role_biologist,dbcon)

# staff_member_with_extended_permissions
role_staff_member_with_extended_permissions = Role(
    ;codeName = RoleCodeName.staff_member_with_extended_permissions,
    composed = true,
    restrictedToAppuserType = AppuserType.staff_member
)
AppuserCtrl.upsert!(role_staff_member_with_extended_permissions,dbcon)

# software_administrator
role_software_administrator = Role(
    ;codeName = RoleCodeName.software_administrator,
    composed = true,
    restrictedToAppuserType = AppuserType.technical_administrator
)
AppuserCtrl.upsert!(role_software_administrator,dbcon)

TRAQUERUtil.closeDBConn(dbcon)

# ######################### #
# Create non-composed Roles #
# ######################### #
dbcon = TRAQUERUtil.openDBConn()

can_modify_user = Role(;codeName = RoleCodeName.can_modify_user, composed = false)
AppuserCtrl.upsert!(can_modify_user,dbcon)

is_doctor = Role(;codeName = RoleCodeName.is_doctor, composed = false)
AppuserCtrl.upsert!(is_doctor,dbcon)

is_nurse = Role(;codeName = RoleCodeName.is_nurse, composed = false)
AppuserCtrl.upsert!(is_nurse,dbcon)

TRAQUERUtil.closeDBConn(dbcon)


# ################## #
# Create roles-assos #
# ################## #

dbcon = TRAQUERUtil.openDBConn()

# Create roles-assos for composed role 'doctor'
role_doctor.handlerRoleRoleRoleAssoes = [
    # Assos to non-composed roles
    RoleRoleAsso(;handledRole = is_doctor),

    # Assos to composed roles (none and it cannot edit users anyway)
]
update_vector_property!(
    role_doctor,
    :handlerRoleRoleRoleAssoes,
    dbcon
)

# Create roles-assos for composed role 'nurse'
role_nurse.handlerRoleRoleRoleAssoes = [
    # Assos to non-composed roles
    RoleRoleAsso(;handledRole = is_nurse),

    # Assos to composed roles (none and it cannot edit users anyway)
]
update_vector_property!(
    role_nurse,
    :handlerRoleRoleRoleAssoes,
    dbcon
)

# Create roles-assos for composed role 'caregiver'
role_caregiver.handlerRoleRoleRoleAssoes = [
    # Assos to non-composed roles
    RoleRoleAsso(;handledRole = is_nurse), # Yes this is not an error, in practice,
                                           #   a caregiver has same permissions as a nurse

    # Assos to composed roles (none and it cannot edit users anyway)
]
update_vector_property!(
    role_caregiver,
    :handlerRoleRoleRoleAssoes,
    dbcon
)

# Create roles-assos for composed role 'secretary'
role_secretary.handlerRoleRoleRoleAssoes = [
    # Assos to non-composed roles

    # Assos to composed roles (none and it cannot edit users anyway)
]
update_vector_property!(
    role_secretary,
    :handlerRoleRoleRoleAssoes,
    dbcon
)

# Create roles-assos for composed role 'biologist'
role_biologist.handlerRoleRoleRoleAssoes = [
    # Assos to non-composed roles

    # Assos to composed roles (none and it cannot edit users anyway)
]
update_vector_property!(
    role_biologist,
    :handlerRoleRoleRoleAssoes,
    dbcon
)


# Create roles-assos for composed role 'staff_member_with_extended_permissions'
role_staff_member_with_extended_permissions.handlerRoleRoleRoleAssoes = [
    # Assos to non-composed roles
    RoleRoleAsso(;handledRole = can_modify_user),

    # Assos to composed roles
    RoleRoleAsso(;handledRole = role_doctor),
    RoleRoleAsso(;handledRole = role_nurse),
    RoleRoleAsso(;handledRole = role_caregiver),
    RoleRoleAsso(;handledRole = role_secretary),
    RoleRoleAsso(;handledRole = role_biologist),
]
update_vector_property!(
    role_staff_member_with_extended_permissions,
    :handlerRoleRoleRoleAssoes,
    dbcon
)

# Create roles-assos for composed role 'software_administrator'
role_software_administrator.handlerRoleRoleRoleAssoes = [
    # Assos to non-composed roles
    RoleRoleAsso(;handledRole = can_modify_user),

    # Assos to composed roles
    RoleRoleAsso(;handledRole = role_doctor),
    RoleRoleAsso(;handledRole = role_nurse),
    RoleRoleAsso(;handledRole = role_caregiver),
    RoleRoleAsso(;handledRole = role_secretary),
    RoleRoleAsso(;handledRole = role_biologist),
    RoleRoleAsso(;handledRole = role_software_administrator),
]
update_vector_property!(
    role_software_administrator,
    :handlerRoleRoleRoleAssoes,
    dbcon
)


TRAQUERUtil.closeDBConn(dbcon)
