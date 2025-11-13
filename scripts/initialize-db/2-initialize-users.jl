using TRAQUER.Enum.AppuserType,TRAQUER.Enum.RoleCodeName
using TRAQUER.Controller.AppuserCtrl

dbcon = TRAQUERUtil.openDBConn()
PostgresORM.delete_entity_alike(Appuser(;login = "psaliou"),dbcon)

doctor = Appuser(
    ;lastname = "Saliou",
    firstname = "Philippe",
    login = "psaliou",
    password = "test_5678",
    appuserType = AppuserType.staff_member
)

role_doctor = retrieve_one_entity(Role(codeName = RoleCodeName.doctor),false,dbcon)
doctor.appuserAppuserRoleAssoes = [AppuserRoleAsso(;role = role_doctor)]
Controller.persist!(doctor)
# AppuserCtrl.createAppuser!(doctor
#                           ;updateVectorProps = true)

TRAQUERUtil.closeDBConn(dbcon)

AppuserCtrl.authenticate("psaliou","test_5678")
