function StayCtrl.getHospitalizationsDates(
    patient::Patient,
    dbconn::LibPQ.Connection
)::DataFrame

    queryString = "
        SELECT DISTINCT
            s.hospitalization_in_time,
            s.hospitalization_out_time
        FROM stay s
        WHERE s.patient_id = \$1"
    return PostgresORM.execute_plain_query(queryString, [patient.id], dbconn)

end
