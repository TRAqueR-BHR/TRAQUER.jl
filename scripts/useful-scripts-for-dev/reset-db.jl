include("__prerequisite.jl")

using Random

function confirm_reset_database()
    confirmation_code = string(rand(Random.default_rng(), 1000:9999))

    println("============================================================")
    println("WARNING: DO NOT RUN THIS SCRIPT FROM A VS CODE JULIA SESSION")
    println("Use a terminal or a manually started Julia REPL instead.")
    println("============================================================")

    println()
    println("Security confirmation: this will reset the database.")
    println("Type this code to continue: $(confirmation_code)")
    print("> ")

    user_input = try
        readline()
    catch err
        error(
            "Interactive confirmation could not read user input in this " *
            "session. Run this script from a terminal or a Julia REPL " *
            "that supports readline(). Original error: $(err)",
        )
    end

    if user_input != confirmation_code
        error("Confirmation failed. Database reset aborted.")
    end

    # Give the user a few seconds to abort the script before proceeding with the database reset.
    println()
    println("Database reset will continue in 5 seconds.")
    println("Press Ctrl+C now to abort.")
    sleep(5)

    return nothing
end

confirm_reset_database()

TRAQUERUtil.createDBConnAndExecute() do dbconn

    "DELETE FROM patient" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM patient_ref_crypt" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM patient_name_crypt" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM patient_birthdate_crypt" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM stay" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM analysis_result" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM infectious_status" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM outbreak" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM contact_exposure" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM analysis_ref_crypt" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

end
