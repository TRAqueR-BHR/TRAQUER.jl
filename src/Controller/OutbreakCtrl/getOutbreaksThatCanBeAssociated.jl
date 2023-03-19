function OutbreakCtrl.getOutbreaksThatCanBeAssociated(
    infectiousStatus::InfectiousStatus, dbconn::LibPQ.Connection
)::Vector{Outbreak}

    outbreaks = "SELECT o.* FROM outbreak o WHERE o.infectious_agent = \$1" |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            Outbreak,
            [infectiousStatus.infectiousAgent],
            false,
            dbconn
        )

    return outbreaks

end
