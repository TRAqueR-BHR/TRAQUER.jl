function StayCtrl.deleteIsolationTime(stay::Stay, dbconn::LibPQ.Connection)

    # Make sure the stay is loaded
    stay = PostgresORM.retrieve_one_entity(stay,false,dbconn)

    stay.isolationTime = missing;
    PostgresORM.update_entity!(stay, dbconn)

end
