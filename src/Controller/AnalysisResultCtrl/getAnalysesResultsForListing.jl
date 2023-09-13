function AnalysisResultCtrl.getAnalysesResultsForListing(
    pageSize::Union{Integer,Missing},
    pageNum::Union{Integer,Missing},
    filtersAndSortings::Vector{Dict{String,Any}}
    ;cryptPwd::Union{String,Missing} = missing
)

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
    FROM analysis_result a
    LEFT JOIN stay s -- an analysis may not have a corresponding stay
        ON a.stay_id = s.id
    INNER JOIN patient p
        ON p.id  = a.patient_id
    "

    if !ismissing(cryptPwd)
        queryStringShared *= "
        JOIN analysis_ref_crypt arc
            ON a.ref_one_char = arc.one_char
            AND a.ref_crypt_id = arc.id
        JOIN patient_birthdate_crypt pbc
            ON  pbc.year = p.birth_year
            AND pbc.id = p.birthdate_crypt_id
        JOIN patient_name_crypt pnc
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

            # Special treatment for filter on the crypted firstname
            elseif (nameInSelect == "firstname" && !ismissing(cryptPwd))
                # Add a first filter on the first letter for performance
                filterValue = lowercase(filterValue)
                # Add the filter itself
                queryStringShared *= "
                    AND pgp_sym_decrypt(pnc.firstname_crypt, \$1)
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
                        *"for enumType[$(paramsDict["enumType"])]"
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


    queryString *= (
        queryStringUsing
        *"SELECT a.*"
    )

    # Add some columns for the decrypted values
    if !ismissing(cryptPwd)
        queryString *= "
            ,pgp_sym_decrypt(arc.ref_crypt, \$1) AS analysis_ref
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
        objects.request_type = passmissing(TRAQUERUtil.string2enum).(
            ANALYSIS_REQUEST_TYPE, objects.request_type)
        objects.sample_material_type = passmissing(TRAQUERUtil.string2enum).(
            SAMPLE_MATERIAL_TYPE, objects.sample_material_type)

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
