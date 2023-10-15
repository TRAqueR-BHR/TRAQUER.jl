function ExposedFunctionCtrl.getFunctions(
    appuser::Appuser,
    dbconn::LibPQ.Connection
)

    if ismissing(appuser.allRoles)
        AppuserCtrl.enrichUserWithRoles!(appuser,dbconn)
    end

    queryString = "
    SELECT f.* FROM misc.exposed_function f
    "
    fcts = PostgresORM.execute_query_and_handle_result(
        queryString,ExposedFunction,missing,false,dbconn
    )
    usersRoles = map(x -> x.codeName,appuser.allRoles)

    # Filter out the functions where none of the role is in the roles of the users
    filter!(
        f -> begin

            for r in f.roles
                if r ∈ usersRoles
                    return true
                end
            end

            return false

        end,
        fcts)


    return fcts

end
