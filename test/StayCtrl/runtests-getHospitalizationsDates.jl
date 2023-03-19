include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getHospitalizationsDates" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        patient = "
        SELECT p.*
        FROM patient p
        INNER JOIN stay s
            ON s.patient_id = p.id
        WHERE p.id = '8176c1b2-e309-485f-be3f-650453a9ede0'
        LIMIT 1" |>
            n -> PostgresORM.execute_query_and_handle_result(
                n, Patient, missing, false, dbconn
            ) |> first
        StayCtrl.getHospitalizationsDates(
            patient,
            dbconn
        )
    end

end
