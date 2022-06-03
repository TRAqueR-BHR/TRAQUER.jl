using TRAQUER.Enum
using TRAQUER.Enum.AppuserType, TRAQUER.Enum.RoleCodeName

#
# Create composed Roles
#

# doctor
dbcon = TRAQUERUtil.openDBConn()
role_doctor = Role(;codeName = RoleCodeName.doctor,
                        nameEn="doctor",
                        nameFr="docteur",
                        composed = true,
                        restrictedToAppuserType = AppuserType.healthcare_professional)
PostgresORM.create_entity!(role_doctor,dbcon)


#
# Create non-composed Roles
#
can_modify_user = Role(;codeName = RoleCodeName.can_modify_user, composed = false)
PostgresORM.create_entity!(can_modify_user,dbcon)


#
# Create assos between roles
#

# Retrieve all non-composed roles so that we have them at hand
can_modify_user = retrieve_one_entity(Role(codeName = RoleCodeName.can_modify_user,
                                           composed = false),
                                      false,
                                      dbcon)

# Retrieve all composed roles so that we have them at hand
role_doctor = retrieve_one_entity(Role(codeName = RoleCodeName.doctor,
                                       composed = true),
                                  false,
                                  dbcon)

# Create roles-assos for composed role 'superadmin'
role_doctor.handlerRoleRoleRoleAssoes = [
      # Assos to non-composed roles
      RoleRoleAsso(;handledRole = can_modify_user),

      # Assos to composed roles
      RoleRoleAsso(;handledRole = role_doctor),
      ]
update_vector_property!(role_doctor,
                        :handlerRoleRoleRoleAssoes,
                        dbcon)


TRAQUERUtil.closeDBConn(dbcon)
