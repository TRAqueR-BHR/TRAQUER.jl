@testset "Test StayCtrl.retrieveOneStayContainingDate" begin
    dbconn = TRAQUERUtil.openDBConn()
    _date = Date("2020-09-01")
    patient = PostgresORM.retrieve_one_entity(Patient(id = "6fbf45d5-b3a0-4b22-9f74-b242ed072e71"),
                                              false,
                                              dbconn)
    stays = StayCtrl.retrieveOneStayContainingDate(patient,_date,dbconn)
    TRAQUERUtil.closeDBConn(dbconn)

    stays[1].inDate - _date
end
