include("getAppusersForListing.jl")
include("upsert.jl")

function AppuserCtrl.setJWT!(appuser::Appuser)

    # payload = Dict("roles" => ["role1","role2"],
    #                "email" => "vincent.laugier@tekliko.com")

    payload = Dict("roles" => getproperty.(appuser.allRoles,:codeName),
                   "login" => appuser.login,
                   "firstname" => appuser.firstname,
                   "lastname" => appuser.lastname,
                   "fullname" => appuser.firstname * " " * appuser.lastname,
                   "userId" => appuser.id)

    jwt = JWT(;payload=payload)

    keyset = JWKSet(getConf("security","jwt_signing_keys_uri"));
    refresh!(keyset)
    keyid = first(first(keyset.keys))

    sign!(jwt, keyset, keyid)
    appuser.jwt = string(jwt)

end

function AppuserCtrl.enrichWithMD5Password!(appuser::Appuser)

    # if !ismissing(appuser.password) && length(appuser.password) != 32
    #     appuser.password = bytes2hex(md5(appuser.password))
    # end

    # If password is not missing and is not encrypted, it means that we are
    #   updating the password.
    @info "length(appuser.password)[$(length(appuser.password))]"
    if (!ismissing(appuser.password)
        && length(appuser.password) < 33)
        dbconn = TRAQUERUtil.openDBConn()
        try
            queryString = "SELECT crypt(\$1, gen_salt('md5'))"
            pwd = PostgresORM.execute_plain_query(
                queryString,[appuser.password],dbconn
            ) |> n -> n[1,1]
            appuser.password = pwd
        catch  e
            rethrow(e)
        finally
            TRAQUERUtil.closeDBConn(dbconn)
        end

    end


end



function Controller.prePersist!(appuser::Appuser)
    AppuserCtrl.enrichWithMD5Password!(appuser)
    if ismissing(appuser.deactivated)
        appuser.deactivated = false
    end
    appuser
end

function Controller.preUpdate!(appuser::Appuser)
    Controller.prePersist!(appuser) # same as prePersist
end


function Controller.updateVectorProps!(
    object::Appuser,
    dbconn::LibPQ.Connection
    ;editor::Union{Missing,Appuser} = missing
)
    AppuserCtrl.updateAppuserAppuserRoleAssos!(
        object,
        dbconn
        ;editor = editor
    )
end

function AppuserCtrl.updateAppuserAppuserRoleAssos!(
    object::Appuser,
    dbconn::LibPQ.Connection,
    ;editor::Union{Missing,Appuser} = missing
)

    PostgresORM.update_vector_property!(object, # updated_object
                            :appuserAppuserRoleAssoes, # updated_property
                            dbconn;
                            editor = editor)


end

function Controller.enrichWithVectorProps!(object::Appuser,
                                dbconn::LibPQ.Connection)
    AppuserCtrl.enrichUserWithRoles!(object,dbconn)
end


function AppuserCtrl.enrichUserWithRoles!(appuser::Appuser,
                              dbconn::Union{Missing, LibPQ.Connection} = missing)

    # Open a db connection if none is given in argument
    need_to_close_dbconn = false
    if ismissing(dbconn)
        dbconn = openDBConnAndBeginTransaction()
        need_to_close_dbconn = true
    end

    try

        #
        # Retrieve the composed roles
        #
        filterObjectFor_rolesAssos = AppuserRoleAsso(;appuser = appuser)
        appuserRoleAssos = retrieve_entity(filterObjectFor_rolesAssos,
                                             true, # Retrieve_complex_props, so that
                                                   #   we get the details of the role
                                             dbconn)
        appuser.appuserAppuserRoleAssoes = appuserRoleAssos

        # Initialize with the composed roles
        appuser.allRoles = getproperty.(appuser.appuserAppuserRoleAssoes,:role)

        #
        # Add the the user type as a role
        #
        appuserTypeAsRoleCodeName =
             TRAQUERUtil.string2enum(RoleCodeName.ROLE_CODE_NAME,string(appuser.appuserType))
        push!(appuser.allRoles, Role(codeName = appuserTypeAsRoleCodeName))

        #
        # Retrieve the non-composed roles as well
        #
        for composedRole in getproperty.(appuser.appuserAppuserRoleAssoes, :role)

            filterObjectForRoleRoleAssos = RoleRoleAsso(;handlerRole = composedRole)

            roleRoleAssos = retrieve_entity(filterObjectForRoleRoleAssos,
                                                true, # Retrieve_complex_props, so that
                                                      #   we get the details of the role
                                                dbconn)

            handledRoles =
                getproperty.(roleRoleAssos,
                             :handledRole)

            # Only keep the non composed roles
            filter!(x -> x.composed == false, handledRoles)
            push!(appuser.allRoles, handledRoles...)

        end

        if need_to_close_dbconn
            commitDBTransaction(dbconn)
        end
        return appuser

    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        # Close the connection if needed
        if need_to_close_dbconn
            closeDBConn(dbconn)
        end
    end

end


function AppuserCtrl.retrieveAppuser(filterObject::Union{Appuser,Missing},
                         includeVectorProps::Bool,
                         appuser::Appuser)

     results = AppuserCtrl.retrieveAppusers(filterObject,includeVectorProps)
     if length(results) > 1
         error(getTranslation("too_many_results",appuser))
     end
     if length(results) == 0
         return missing
     end

     result = results[1]



     return result


end

function AppuserCtrl.retrieveAppusers(filterObject::Union{Appuser,Missing},
                         includeVectorProps::Bool)
    dbconn = openDBConnAndBeginTransaction()

    try
        result = retrieve_entity(filterObject,
                                 true, # retrieve_complex_props
                                 dbconn)

        # Retrieve Roles assos
        if includeVectorProps
             AppuserCtrl.enrichWithVectorProps!.(result,dbconn)
        end

        return result
    finally
        closeDBConn(dbconn)
    end
end

function AppuserCtrl.retrieveAppusers()
    AppuserCtrl.retrieveAppusers(missing,
                    false # includeVectorProps
                    )
end

function AppuserCtrl.retrieveActiveAppusers(caller::Appuser
                               ;restrictedToRoles::Vector{Role} = Role[])

    roleIDsAccessibleToUser =
           getproperty.(RoleDAO.getComposedRolesAccessibleToUser(caller),
                        :id)


    if !isempty(restrictedToRoles)
        restrictedToRolesIDs =
            getproperty.(restrictedToRoles,
                         :id)

        @info restrictedToRolesIDs
        filter!(x -> x in restrictedToRolesIDs, roleIDsAccessibleToUser)
    end

    queryString = "
    SELECT DISTINCT appuser.*
    FROM appuser
    JOIN appuser_role_asso ara
      ON ara.appuser_id = appuser.id
    WHERE ara.role_id = ANY(\$1)
    AND appuser.deactivated = 'f'
    "
    queryArgs = [roleIDsAccessibleToUser]

    dbconn = TRAQUERUtil.openDBConn()
    activeUsers = Appuser[];
    try

        activeUsers =
            PostgresORM.execute_query_and_handle_result(queryString,
                                                        Appuser,
                                                        queryArgs,
                                                        false,
                                                        dbconn)
    catch e
        rethrow(e)
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end
    return activeUsers
end


function AppuserCtrl.authenticate(login::AbstractString, password::AbstractString)

    #
    # 1. Check that the password match the login
    #
    dbconn = TRAQUERUtil.openDBConn()
    _match = try
        queryString = "
            SELECT (password = crypt(\$2, password))
            AS pswmatch FROM usersch.appuser
            WHERE login = \$1 AND deactivated = false"
        PostgresORM.execute_plain_query(queryString,
                                        [login,password],
                                         dbconn) |>
                 n -> if isempty(n) false else n[1,1] end

    catch e
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        false
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end

    if !_match
        return missing
    end

    #
    # 2. Retrieve the user and his roles
    #
    filterUser = Appuser(;login = login,
                         # password = bytes2hex(md5(password)),
                         deactivated = false)

    appusers = Controller.retrieveEntities(
        filterUser,
        retrieveComplexProps = true,
        includeVectorProps = true
    )

    if isempty(appusers)
        return(missing)
    end

    appuser = appusers[1]

    AppuserCtrl.setJWT!(appuser)

    return(appuser)
end


function AppuserCtrl.updateVectorProps!(object::Role,
                                        dbconn::LibPQ.Connection
                                        ;editor::Union{Appuser, Missing} = missing)

      PostgresORM.
        update_vector_property!(object, # updated_object
                               :roleRoleAssos_as_handler, # updated_property
                               dbconn;
                               editor = editor)
      PostgresORM.
        update_vector_property!(object, # updated_object
                                :roleRoleAssosAsHandled, # updated_property
                                dbconn;
                                editor = editor)
end

function AppuserCtrl.getComposedRolesAccessibleToUser(
              appuser::Appuser
             ;appuserType::Union{Missing,AppuserType.APPUSER_TYPE} = missing
          )

    dbconn = openDBConn()
    try
        query_string =
           "SELECT
            -- 'DISTINCT' is needed because the user can have several roles
            --   handling the same role
            DISTINCT handled_role.*
            FROM usersch.role handler_role
            INNER JOIN usersch.role_role_asso rrasso
              ON rrasso.handler_role_id = handler_role.id
            INNER JOIN usersch.role handled_role
              ON rrasso.handled_role_id = handled_role.id
            WHERE
                  handled_role.composed = 't'
              AND handler_role.id = ANY(\$1)"

        if !ismissing(appuserType)
            query_string *= " AND handled_role.restricted_to_appuser_type = \$2"
        end

        composed_roles_ids = map(x -> getproperty(getproperty(x,:role),:id),
                                 appuser.appuserAppuserRoleAssoes)
        # @info join(composed_roles_ids,",")

        # @info getproperty.(appuser.appuserAppuserRoleAssoes,:role)

        # Create the array of query arguments
        query_args = []
        push!(query_args,composed_roles_ids)
        if !ismissing(appuserType)
            push!(query_args,Int8(appuserType))
        end

        result = PostgresORM.
            execute_query_and_handle_result(query_string,
                                            Role,
                                            query_args, # query_args
                                            false, # retrieve_complex_props
                                            dbconn::LibPQ.Connection)

        # Add the composed roles of the user himself
        usersComposedRoles = getproperty.(appuser.appuserAppuserRoleAssoes,:role)
        push!(result,
              usersComposedRoles...)

        # Remove possible duplicates because a composed role of the user may
        #   also has been added as a handled role of oneof the user's roles
        unique!(x -> x.id, result)

        @info result

        return(result)
    catch e
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end

end


function AppuserCtrl.getComposedRolesForListing(appuser::Appuser)

    if (!hasRole(appuser, RoleCodeName.can_search_roles))
            error("unauthorized_access")
    end

    dbconn = openDBConn()
    try
        queryString =
           "-- We need a 'WITH' query because of the WHERE clause
            WITH roles_assos AS (
            SELECT role.id AS role_id,
            	   string_agg(DISTINCT related_noncomposed_role.code_name::text, ', '::text) AS noncomposed_roles_code_names,
            	   string_agg(DISTINCT related_composed_role.code_name::text, ', '::text) AS composed_roles_code_names,
            	   string_agg(DISTINCT related_noncomposed_role.name_en::text, ', '::text) AS noncomposed_roles_names_en,
            	   string_agg(DISTINCT related_noncomposed_role.name_fr::text, ', '::text) AS noncomposed_roles_names_fr,
            	   string_agg(DISTINCT related_composed_role.name_en::text, ', '::text) AS composed_roles_names_en,
            	   string_agg(DISTINCT related_composed_role.name_fr::text, ', '::text) AS composed_roles_names_fr

                        FROM role
                        INNER JOIN role_role_asso rrasso_noncomposed
                          ON rrasso_noncomposed.handler_role_id = role.id
            			INNER JOIN role AS related_noncomposed_role
            			  ON rrasso_noncomposed.handled_role_id = related_noncomposed_role.id
                        INNER JOIN role_role_asso rrasso_composed
                          ON rrasso_composed.handler_role_id = role.id
            			INNER JOIN role AS related_composed_role
            			  ON rrasso_composed.handled_role_id = related_composed_role.id
                        WHERE
                              role.composed = 't'
            			AND   related_noncomposed_role.composed = 'f'
            			AND   related_composed_role.composed = 't'
            		    GROUP BY
            				role.id
            )
            SELECT
                role.id,
            	role.code_name,
                role.restricted_to_appuser_type,
                role.name_en,
                role.name_fr,
            	roles_assos.noncomposed_roles_code_names,
            	roles_assos.composed_roles_code_names,
            	roles_assos.noncomposed_roles_names_en,
            	roles_assos.noncomposed_roles_names_fr,
            	roles_assos.composed_roles_names_en,
            	roles_assos.composed_roles_names_fr
            FROM role
            LEFT JOIN roles_assos
              ON role.id = roles_assos.role_id
            WHERE
              role.composed = 't'
"

        result = PostgresORM.
            execute_plain_query(queryString,
                                      missing, # queryArgs
                                      dbconn)
        return(result)
    catch e
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end

end
