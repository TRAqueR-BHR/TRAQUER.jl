function InfectiousStatusCtrl.getInfectiousStatusForListing(
            pageSize::Union{Integer,Missing},
            pageNum::Union{Integer,Missing},
            filtersAndSortings::Vector{Dict{String,Any}}
            ;cryptPwd::Union{String,Missing} = missing)

    # Filter and sort
    # NOTE: filtersAndSortings is an array
    sortings = String[]
    dfSortings = Vector{DataFrames.UserColOrdering{Symbol}}()

    # Sort the vector based on the sorting rank
    filter!(x -> haskey(x, "sortingRank"), filtersAndSortings)
    sort!(filtersAndSortings, by = x -> x["sortingRank"])

    args_counter = 0
    queryString = ""
    queryStringUsing = ""
    queryArgs::Vector{Any} = []

    # If crypt password is given, set it as the first argument of the query
    if !ismissing(cryptPwd)
        push!(queryArgs,cryptPwd)
    end

    queryStringShared = "
        FROM infectious_status ist
        INNER JOIN event_requiring_attention era
          ON era.infectious_status_id = ist.id
        INNER JOIN patient p
          ON p.id = ist.patient_id
        LEFT JOIN outbreak_infectious_status_asso oisa
          ON ist.id = oisa.infectious_status_id
        LEFT JOIN outbreak o
          ON oisa.outbreak_id = o.id
        LEFT JOIN unit patient_current_unit
          ON  p.current_unit_id = patient_current_unit.id
    "

    if !ismissing(cryptPwd)
        queryStringShared *= "
          INNER JOIN patient_birthdate_crypt pbc
             ON  pbc.year = p.birth_year
            AND pbc.id = p.birthdate_crypt_id
          INNER JOIN patient_name_crypt pnc
             ON  pnc.lastname_first_letter = p.lastname_first_letter
            AND pnc.id = p.name_crypt_id
        "
    end

    queryStringShared *= "
    WHERE 1 = 1 -- for convenience
    "

    args_counter = length(queryArgs)
    for paramsDict in filtersAndSortings

        # Skip the columns without 'nameInSelect'
        # This allows to put special columns for display only
        #  (eg.  the 'action' column)
        if (!haskey(paramsDict,"nameInSelect")
          || ismissing(paramsDict["nameInSelect"]))
            continue
        end

        attrName = paramsDict["nameInSelect"]

        # Check that we have the attributeType
        if (ismissing(paramsDict["attributeType"]))
            @warn "Missing an attributeType for filter on $attrName"
            continue
        end

        # Check that we have the nameInWhereClause
        if (ismissing(paramsDict["nameInWhereClause"]))
            @warn "Missing an nameInWhereClause for filter on $attrName"
            continue
        end

        nameInWhereClause = paramsDict["nameInWhereClause"]
        nameInSelect = paramsDict["nameInSelect"]

        # Add the WHERE clauses for the filters
        if (!ismissing(paramsDict["filterIsActive"])
            && paramsDict["filterIsActive"] == true
            && !ismissing(paramsDict["filterValue"]))

            filterValue = paramsDict["filterValue"]

            # Special treatment for filter on the crypted lastname
            if (nameInSelect == "lastname" && !ismissing(cryptPwd))
                # Add a first filter on the first letter for performance
                filterValue = lowercase(filterValue)
                queryStringShared *= "
                    AND pnc.lastname_first_letter = \$$(args_counter += 1)"
                push!(queryArgs,filterValue[1])
                # Add the filter itself
                queryStringShared *= "
                    AND pgp_sym_decrypt(pnc.lastname_crypt, \$1)
                        ILIKE \$$(args_counter += 1) "
                push!(queryArgs,(filterValue * "%"))

            # Create a different WHERE clause for text
            elseif (paramsDict["attributeType"] == "text" ||
                paramsDict["attributeType"] == "string")

                # For arrays of string
                if (haskey(paramsDict,"attributeTest")
                 && uppercase(paramsDict["attributeTest"]) == "IN")
                    queryStringShared *= " AND $nameInWhereClause = ANY(\$$(args_counter += 1)) "
                    push!(queryArgs, unique(filterValue))
                else
                    queryStringShared *= " AND $nameInWhereClause ILIKE \$$(args_counter += 1) "
                    push!(queryArgs,("%" * filterValue * "%"))
                end

            elseif (paramsDict["attributeType"] == "enum")
                queryStringShared *= " AND $nameInWhereClause = ANY(\$$(args_counter += 1)) "
                if isa(filterValue, String)
                    push!(queryArgs, [filterValue])
                elseif isa(filterValue, Vector{String})
                    push!(queryArgs, unique(filterValue))
                elseif isa(filterValue, Integer)
                    enumType = TRAQUERUtil.string2type(paramsDict["enumType"])
                    push!(queryArgs, [TRAQUERUtil.int2enum(enumType,filterValue)])
                elseif isa(filterValue, Vector{<:Integer})
                    enumType = TRAQUERUtil.string2type(paramsDict["enumType"])
                    push!(queryArgs, TRAQUERUtil.int2enum.(enumType,filterValue))
                else
                    error(
                        "Unsupported filterValue[$(typeof(filterValue))] "
                        *"for enumType[$(enumType)]"
                    )
                end
            else
                queryStringShared *= " AND $nameInWhereClause = \$$(args_counter += 1) "
                push!(queryArgs, filterValue)
            end

        end # ENDOF WHERE clauses for the filters


        # Add the ORDER clause for the SQL query string and the vector of
        #    DataFrames.UserColOrdering for the final sorting of the dataframe
        # NOTE: The final sorting of the dataframe is needed because the
        #       various types of joins no longer preserve the order of the
        #       left dataframe
        #       (see https://github.com/JuliaData/DataFrames.jl/blob/main/NEWS.md#other-relevant-changes)
        if !ismissing(paramsDict["sorting"])

            # For the SQL query
            _order = (paramsDict["sorting"] == 1) ? " ASC " : " DESC "
            push!(sortings,nameInWhereClause * _order)

            # For the final dataframe sort
            _rev = (paramsDict["sorting"] == 1) ? false : true
            push!(dfSortings,
                  order(Symbol(nameInSelect), rev = _rev))

        end

    end # ENDOF for paramsDict in filtersAndSortings

    # Create the 'ORDER BY' part
    # NOTE : 'ORDER BY' doit utilisé dans la pré-requête mais aussi dans
    #         la  requête principale
    orderByClause = ""
    if (length(sortings) > 0)
        orderByClause = " ORDER BY " * join(sortings,",")
    end


    queryString *= (queryStringUsing
        * "SELECT p.id AS patient_id,
                  p.traquer_ref AS traquer_ref,
                  p.birthdate_crypt_id AS birthdate_crypt_id,
                  p.birthdate_crypt_id AS birth_year,
                  p.is_hospitalized AS patient_is_hospitalized,
                  ist.id AS infectious_status_id,
                  ist.ref_time AS ref_time,
                  ist.infectious_status,
                  ist.infectious_agent,
                  ist.is_confirmed,
                  ist.is_current,
                  era.id AS event_id,
                  era.response_time AS event_response_time,
                  era.response_user_id AS event_response_user_id,
                  era.response_comment AS event_response_comment,
                  era.responses_types AS event_responses_types,
                  era.event_type AS event_type,
                  era.ref_time AS event_ref_time,
                  era.is_pending AS event_is_pending,
                  patient_current_unit.code_name AS current_unit_code_name,
                  patient_current_unit.name AS current_unit_name,
                  o.name AS outbreak_name
                  ")

    # Add some columns for the decrypted values
    if !ismissing(cryptPwd)
        queryString *= "
            ,pgp_sym_decrypt(pbc.birthdate_crypt, \$1) AS birthdate
            ,pgp_sym_decrypt(pnc.firstname_crypt, \$1) AS firstname
            ,pgp_sym_decrypt(pnc.lastname_crypt, \$1) AS lastname
        "
    end

    queryString *= queryStringShared

    if (length(sortings) > 0)
        queryString *= " ORDER BY " * join(sortings,",")
    end
    queryString *= "
    LIMIT \$$(args_counter += 1) "
    queryString *= "
    OFFSET \$$(args_counter += 1)"

    @info typeof(queryString)
    # NOTE: This will equal to missing if pageSize is missing
    #       which results in passing NULL to the query which does work
    offset = (pageNum - 1) * pageSize

    println(queryString)
    @info queryArgs

    objects = missing

    dbconn = TRAQUERUtil.openDBConn()
    try

        objects = execute_plain_query(queryString,
                                     [queryArgs...,pageSize,offset], # queryArgs
                                      dbconn)

        # ##################################### #
        # Transform the columns that need to be #
        # ##################################### #
        @info "names(objects)" names(objects)
        if !ismissing(cryptPwd)
            objects.birthdate = passmissing(TRAQUERUtil.string2date).(objects.birthdate)
        end
        objects.infectious_status = passmissing(TRAQUERUtil.string2enum).(
            INFECTIOUS_STATUS_TYPE, objects.infectious_status)
        objects.infectious_agent = passmissing(TRAQUERUtil.string2enum).(
            INFECTIOUS_AGENT_CATEGORY, objects.infectious_agent)
        objects.event_type = passmissing(TRAQUERUtil.string2enum).(
            EVENT_REQUIRING_ATTENTION_TYPE, objects.event_type)

    catch e
        rethrow(e)
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end

    totalRecords = typemax(Int64)

    if length(dfSortings) > 0
        sort!(objects,dfSortings)
    end

    result = Dict(:rows => objects, :totalRecords => totalRecords)

    return result

end
