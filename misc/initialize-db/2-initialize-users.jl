using TRAQUER.Enum.AppuserType,TRAQUER.Enum.RoleCodeName
using TRAQUER.Controller.AppuserCtrl

dbcon = TRAQUERUtil.openDBConn()
PostgresORM.delete_entity_alike(Appuser(;login = "psaliou"),dbcon)

doctor = Appuser(;lastname = "Saliou",
                  firstname = "Saliou",
                  login = "psaliou",
                  password = "test5678",
                  appuserType = AppuserType.healthcare_professional)

role_doctor = retrieve_one_entity(Role(codeName = RoleCodeName.doctor),false,dbcon)
doctor.appuserAppuserRoleAssoes = [AppuserRoleAsso(;role = role_doctor)]
AppuserCtrl.createAppuser!(doctor
                          ;updateVectorProps = true)

TRAQUERUtil.closeDBConn(dbcon)

AppuserCtrl.authenticate("psaliou","test5678")
