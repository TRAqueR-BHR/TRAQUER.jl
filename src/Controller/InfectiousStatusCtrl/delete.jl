function InfectiousStatusCtrl.delete(infectiousStatus::InfectiousStatus, dbconn::LibPQ.Connection)

    DeletedInfectiousStatusCtrl.create(
        infectiousStatus,
        dbconn
    )

    PostgresORM.delete_entity(infectiousStatus, dbconn)

    return infectiousStatus

end
