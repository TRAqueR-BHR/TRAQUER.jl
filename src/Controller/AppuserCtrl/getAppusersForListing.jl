function AppuserCtrl.getAppusersForListing(appuser::Appuser)

    dbconn = openDBConn()

    # We make sure that the calling user is allowed to list users
    # if !hasRole(appuser,RoleCodeName.can_search_users)
    #     throw(DomainError("Forbidden access"))
    # end

    try
        # NOTE: Cannot make an alias with uppercase like 'user.creationTime',
        #         it arrives null on the client side.

        queryString = ""

        queryString *= "SELECT appuser.id AS \"appuser_id\",
            appuser.lastname AS \"appuser_lastname\",
            appuser.firstname AS \"appuser_firstname\",
            appuser.login AS \"appuser_login\",
            appuser.appuser_type AS \"appuser_type\",
            appuser.deactivated,
            --ARRAY_AGG(DISTINCT role.code_name::character varying) AS \"appuser_roles\"
            STRING_AGG(DISTINCT role.code_name::character varying, ', ') AS \"appuser_roles\"
            FROM usersch.appuser appuser "

        queryString *= "
                INNER JOIN usersch.appuser_role_asso role_asso
                    ON appuser.id = role_asso.appuser_id
                INNER JOIN usersch.role role
                    ON role.id = role_asso.role_id
                "

        queryString *= "
            GROUP BY appuser.id,
                     appuser.lastname,
                     appuser.firstname,
                     appuser.login,
                     appuser.deactivated"


        #  if appuser.appuserType != AppuserType.ip_owner_collaborator
        #      queryArgs = [appuser.id]
        #  else
        #      queryArgs = missing
        #  end

        queryArgs = missing

        println(queryString)

        result = execute_plain_query(queryString,
                                      queryArgs, # query_args
                                      dbconn)
        result.appuser_roles = map(
            x -> split(x,",") |> n -> strip.(n) |> n -> string.(n),
            result.appuser_roles)
        return(result)
     catch e
         rethrow(e)
     finally
         closeDBConn(dbconn)
     end

end
