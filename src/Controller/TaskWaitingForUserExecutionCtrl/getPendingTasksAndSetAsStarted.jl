"""
    TaskWaitingForUserExecutionCtrl.getPendingTasksAndSetAsStarted()::Vector{TaskWaitingForUserExecution}

Return and set as started the pending instances of TaskWaitingForUserExecution, in a concurrent way.

"""
function TaskWaitingForUserExecutionCtrl.getPendingTasksAndSetAsStarted()::Vector{TaskWaitingForUserExecution}

    # https://www.dbrnd.com/2017/01/postgresql-how-to-apply-access-exclusive-lock-mode-on-table-share-lock-update-lock-row-lock/

    tasks = createDBConnAndExecute() do dbconn
        execute(dbconn, "BEGIN TRANSACTION")
        execute(dbconn,"LOCK TABLE misc.task_waiting_for_user_execution IN ACCESS EXCLUSIVE MODE")

        # Get the list of unfinished tasks
        queryString = "
            SELECT t.*
            FROM misc.task_waiting_for_user_execution t
            WHERE t.start_time IS NOT NULL
              AND t.end_or_error_time IS NULL"

        unfinishedTasksNames = PostgresORM.execute_query_and_handle_result(
            queryString,
            TaskWaitingForUserExecution,
            missing,
            false, # complex props
            dbconn
        )|> n -> getproperty.(n, :name)

        # Get the list of not yet started tasks
        queryString = "
            SELECT t.*
            FROM misc.task_waiting_for_user_execution t
            WHERE t.start_time IS NULL"

        tasks = PostgresORM.execute_query_and_handle_result(
            queryString,
            TaskWaitingForUserExecution,
            missing,
            false, # complex props
            dbconn
        )

        # Ignore the tasks in the blacklist
        filter!(x -> x.name ∉ TRAQUERUtil.getTaskWaitingForUserExecutionBlacklist(), tasks)

        # Ignore the tasks where there is another task running for that same function
        filter!(x -> x.name ∉ unfinishedTasksNames, tasks)

        # Remove the duplicated tasks (happens when the scheduler had the time to create
        # several rows of a pending task for a function before we had the time to execute any)
        functionNameToTask = Dict{String,TaskWaitingForUserExecution}()
        for t in tasks
            # If a task was already added to the dictionnary for that function, delete the task
            if haskey(functionNameToTask, t.name)
                PostgresORM.delete_entity(t, dbconn)
            else
                functionNameToTask[t.name] = t
                t.startTime = now(getTimeZone())
                PostgresORM.update_entity!(t, dbconn)
            end
        end

        # Set the tasks has started
        # @info map(x -> x.id,values(functionNameToTask))
        # @info map(x -> x.id,values(functionNameToTask)) |> typeof
        # ids = map(x -> x.id,values(functionNameToTask))
        # ids = ["d6c28c2f-d618-413f-8a44-f48ce1de1724"]
        # "UPDATE misc.task_waiting_for_user_execution
        # SET start_time = \$1
        # WHERE id = ANY(\$2)"|>
        #     n -> PostgresORM.execute_plain_query(
        #             n,
        #             [now(getTimeZone()) , ids],
        #             dbconn
        #         )

        execute(dbconn, "COMMIT TRANSACTION")

        return (collect ∘ values)(functionNameToTask)
    end

    return tasks

end
