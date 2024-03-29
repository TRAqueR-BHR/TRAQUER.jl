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
    prequeryString = ""
    queryArgs::Vector{Any} = []

    # If crypt password is given, set it as the first argument of the query
    if !ismissing(cryptPwd)
        push!(queryArgs,cryptPwd)
    end

    prequeryString = "
        SELECT  p.id AS patient_id,
                p.traquer_ref AS traquer_ref,
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
                o.id AS outbreak_id,
                o.name AS outbreak_name,

                -- The following are for joining with the main query
                p.birth_year AS patient_birth_year,
                p.birthdate_crypt_id AS patient_birthdate_crypt_id,
                p.lastname_first_letter AS patient_lastname_first_letter,
                p.name_crypt_id AS patient_name_crypt_id,
                p.ref_one_char AS patient_ref_one_char,
                p.ref_crypt_id AS patient_ref_crypt_id

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
        prequeryString *= "
          INNER JOIN patient_birthdate_crypt pbc
            ON  pbc.year = p.birth_year
            AND pbc.id = p.birthdate_crypt_id
          INNER JOIN patient_name_crypt pnc
            ON  pnc.lastname_first_letter = p.lastname_first_letter
            AND pnc.id = p.name_crypt_id
          INNER JOIN patient_ref_crypt prc
            ON  prc.one_char = p.ref_one_char
            AND prc.id = p.ref_crypt_id
        "
    end

    prequeryString *= "
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

            # Special treatment for filter on the crypted patient ref.
            if (nameInSelect == "patient_ref" && !ismissing(cryptPwd))
                # Add a first filter on the first letter for performance
                filterValue = lowercase(filterValue)
                prequeryString *= "
                    AND prc.one_char = \$$(args_counter += 1)"
                push!(queryArgs, PatientCtrl.getRefOneChar(filterValue))
                # Add the filter itself
                prequeryString *= "
                    AND pgp_sym_decrypt(prc.ref_crypt, \$1)
                        ILIKE \$$(args_counter += 1) "
                push!(queryArgs,(filterValue * "%"))

            # Special treatment for filter on the crypted lastname
            elseif (nameInSelect == "lastname" && !ismissing(cryptPwd))
                # Add a first filter on the first letter for performance
                filterValue = TRAQUERUtil.cleanStringForEncryptedValueCp(filterValue)
                prequeryString *= "
                    AND pnc.lastname_first_letter = \$$(args_counter += 1)"
                push!(queryArgs,filterValue[1])
                # Add the filter itself
                prequeryString *= "
                    AND pgp_sym_decrypt(pnc.lastname_for_cp_crypt, \$1)
                        ILIKE \$$(args_counter += 1) "
                push!(queryArgs,(filterValue * "%"))

            # Special treatment for filter on the crypted firstname
            elseif (nameInSelect == "firstname" && !ismissing(cryptPwd))
                filterValue = lowercase(filterValue)
                # Add the filter itself
                prequeryString *= "
                    AND pgp_sym_decrypt(pnc.firstname_crypt, \$1)
                        ILIKE \$$(args_counter += 1) "
                push!(queryArgs,(filterValue * "%"))

            elseif (nameInSelect == "birthdate" && !ismissing(cryptPwd))

                # Convert to Date if needed
                if isa(filterValue,Date)
                    # All good do nothing
                elseif isa(filterValue,AbstractString)
                    filterValue = TRAQUERUtil.string2date(filterValue)
                else
                    error(
                        ("Unexpected type[$(typeof(filterValue))] for input"
                        * " birthdate[$filterValue]")
                    )
                end

                # Add a first filter on the year for performance
                prequeryString *= "
                    AND pbc.year = \$$(args_counter += 1)"
                push!(queryArgs,year(filterValue))

                # Add the filter itself
                prequeryString *= "
                    AND pgp_sym_decrypt(pbc.birthdate_crypt, \$1)
                        = \$$(args_counter += 1) "
                push!(
                    queryArgs,
                    string(filterValue)
                )

            # Create a different WHERE clause for text
            elseif (paramsDict["attributeType"] == "text" ||
                paramsDict["attributeType"] == "string")

                # For arrays of string
                if (haskey(paramsDict,"attributeTest")
                 && uppercase(paramsDict["attributeTest"]) == "IN")
                    prequeryString *= " AND $nameInWhereClause = ANY(\$$(args_counter += 1)) "
                    push!(queryArgs, unique(filterValue))
                else
                    prequeryString *= " AND $nameInWhereClause ILIKE \$$(args_counter += 1) "
                    push!(queryArgs,("%" * filterValue * "%"))
                end

            elseif (paramsDict["attributeType"] == "enum")
                prequeryString *= " AND $nameInWhereClause = ANY(\$$(args_counter += 1)) "
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
                prequeryString *= " AND $nameInWhereClause = \$$(args_counter += 1) "
                push!(queryArgs, filterValue)
            end

        end # ENDOF WHERE clauses for the filters


        # Add the ORDER clause for the SQL query string and the vector of
        #    DataFrames.UserColOrdering for the final sorting of the dataframe
        # NOTE: The final sorting of the dataframe is needed because the
        #       various types of joins no longer preserve the order of the
        #       left dataframe
        #       (see https://github.com/JuliaData/DataFrames.jl/blob/main/NEWS.md#other-relevant-changes)

        # Add default sorting on 'event_ref_time'
        if paramsDict["field"] == "event_ref_time" && ismissing(paramsDict["sorting"])
            paramsDict["sorting"] = -1
        end

        if !ismissing(paramsDict["sorting"])

            # For the SQL query
            _order = (paramsDict["sorting"] == 1) ? " ASC " : " DESC "
            push!(sortings,nameInWhereClause * _order)

            # For the final dataframe sort
            _rev = (paramsDict["sorting"] == 1) ? false : true
            push!(dfSortings, order(Symbol(nameInSelect), rev = _rev))

        end

    end # ENDOF for paramsDict in filtersAndSortings

    # Create the 'ORDER BY' part
    # NOTE : 'ORDER BY' doit utilisé dans la pré-requête mais aussi dans
    #         la  requête principale
    if (length(sortings) > 0)
        prequeryString *= " ORDER BY " * join(sortings,",")
    end
    prequeryString *= "
    LIMIT \$$(args_counter += 1) "
    prequeryString *= "
    OFFSET \$$(args_counter += 1)"

    # NOTE: This will equal to missing if pageSize is missing
    #       which results in passing NULL to the query which does work
    offset = (pageNum - 1) * pageSize


    queryString *= (
        "
        WITH prequery AS (
            $prequeryString
        )
        "
        *"
        SELECT prequery.*
        "
    )

    # Add some columns for the decrypted values
    if !ismissing(cryptPwd)
        queryString *= "
            ,pgp_sym_decrypt(pbc.birthdate_crypt, \$1) AS birthdate
            ,pgp_sym_decrypt(pnc.firstname_crypt, \$1) AS firstname
            ,pgp_sym_decrypt(pnc.lastname_crypt, \$1) AS lastname
            ,pgp_sym_decrypt(prc.ref_crypt, \$1) AS patient_ref
        "
    end

    queryString *= "
        FROM prequery
        "
    # Add the required joins for the crypted values
    if !ismissing(cryptPwd)
        queryString *= "
            JOIN patient_birthdate_crypt pbc
              ON  pbc.year = prequery.patient_birth_year
              AND pbc.id = prequery.patient_birthdate_crypt_id
            JOIN patient_name_crypt pnc
              ON  pnc.lastname_first_letter = prequery.patient_lastname_first_letter
              AND pnc.id = prequery.patient_name_crypt_id
            JOIN patient_ref_crypt prc
              ON  prc.one_char = prequery.patient_ref_one_char
              AND prc.id = prequery.patient_ref_crypt_id
        "
    end

    objects = missing

    dbconn = TRAQUERUtil.openDBConn()
    try

        # println(queryString)

        objects = execute_plain_query(queryString,
                                     [queryArgs...,pageSize,offset], # queryArgs
                                      dbconn)

        # ##################################### #
        # Transform the columns that need to be #
        # ##################################### #
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

    # Final sorting of the dataframe because the final query does not guarantee to respect
    # the order of the prequery
    if length(dfSortings) > 0
        sort!(objects,dfSortings)
    end

    result = Dict(:rows => objects, :totalRecords => totalRecords)

    return result

end
