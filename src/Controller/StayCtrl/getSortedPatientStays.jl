function StayCtrl.getSortedPatientStays(
    patient::Patient, dbconn::LibPQ.Connection
)::Vector{Stay}

    # Get the list of all the stays of this patient
    stays = "
        SELECT s.*
        FROM stay s
        WHERE s.patient_id = \$1" |>
        n -> @mock PostgresORM.execute_query_and_handle_result(
            n,
            Stay,
            [passmissing(getproperty)(patient,:id)],
            false,
            dbconn)

    # Sort
    sort!(stays ;by = x -> x.inTime)

    return stays

end
