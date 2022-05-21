function InfectiousStatusCtrl.createInfectiousStatusIfNotExist(
                                    infectiousStatus::InfectiousStatus)

end

function InfectiousStatusCtrl.generateCarrierStatusesForEPC(startDate::Date,
                                                            dbconn::LibPQ.Connection)

    queryString = "
        SELECT a.*
        FROM analysis a
        INNER JOIN analysis_type t
          ON a.analysis_type_id = t.id
        INNER JOIN patient p
          ON p.id  = a.patient_id
        INNER JOIN stay s
          on a.stay_id = s.id
        WHERE t.code_name = 'GXEPC'
        AND result_value = ANY('{PIMP,PVIM,PNDM,PKPC,POXA}')
        AND s.in_date >= \$1"
    queryArgs  = [startDate]
    try
        analyses = PostgresORM.execute_query_and_handle_result(queryString,
                                                    Analysis,
                                                    queryArgs,
                                                    false, # complex props
                                                    dbconn)

        infectionType = PostgresORM.retrieve_one_entity(
            InfectionType(codeName = "ARB_CPE"),
            false,
            dbconn)
        if ismissing(infectionType)
            error("Missing an entry in table infection_type for ARB_CPE")
        end

        for a in analyses
            infectiousStatusFilter =
                InfectiousStatus(patient = a.patient,
                                 type = infectionType,
                                 carrierContact = CarrierContact.carrier,
                                 refTime = a.requestDateTime)
            existingInfectiousStatus =
                PostgresORM.retrieve_one_entity(infectiousStatusFilter,
                                                false,
                                                dbconn)
            if ismissing(existingInfectiousStatus)
                PostgresORM.create_entity!(infectiousStatusFilter,dbconn)
            end

        end

    catch e
        rethrow(e)
    end

end


function InfectiousStatusCtrl.generateContactExposures(startDate::Date,
                                                       dbconn::LibPQ.Connection)

    queryString = "SELECT * FROM infectious_status i
                   WHERE i.carrier_contact = 'carrier'
                    AND ref_time >= \$1
                    "
    queryArgs = [startDate]
    try
        infectiousStatuses =
            PostgresORM.execute_query_and_handle_result(queryString,
                                                        InfectiousStatus,
                                                        queryArgs,
                                                        dbconn)
    catch e

    end


end

function InfectiousStatusCtrl.generateContactExposures(infectiousStatus::InfectiousStatus,
                                                       dbconn::LibPQ.Connection)

   # Check that the infectiousStatus is a `carrier`
   if infectiousStatus.carrierContact != Enum.CarrierContact.carrier
       return
   end

   # Get the relevant stays and units of the patient
   queryString = "
      SELECT s.*
      FROM stay s
      WHERE s.patient_id = \$1
   "
   queryArgs = [infectiousStatus.patient.id]
   carrierStays =
     PostgresORM.execute_query_and_handle_result(queryString,
                                                 Stay,
                                                 queryArgs,
                                                 false,
                                                 dbconn)

   # Find all the patients staying in the same units at the same time
   queryString = "
      SELECT s.*
      FROM stay s
      WHERE s.in_date >= \$1 -- This is for performance, in order to take
                             --   advantage of the partitioning.
                             -- CAUTION: We need to take a large margin for \$1

        AND s.unit_id = \$2
        AND (  \$3 BETWEEN s.in_date_time AND s.out_date_time
            OR \$4 BETWEEN s.in_date_time AND s.out_date_time  )
   "

   contactStays = Stay[]
   for carrierStay in carrierStays

       restrictionForPartition = carrierStay.inDate - Month(1)

       queryArgs = [restrictionForPartition, # for perf
                    carrierStay.unit.id,
                    carrierStay.inDateTime,
                    carrierStay.outDateTime]
       push!(contactStays,
             PostgresORM.execute_query_and_handle_result(queryString,
                                                         Stay,
                                                         queryArgs,
                                                         false,
                                                         dbconn)...
             )


   end

   contactStays

end


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
        FROM public.infectious_status _is
        INNER JOIN patient p
          ON p.id = _is.patient_id
        INNER JOIN infection_type ist
          ON ist.id = _is.type_id
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
    WHERE _is.id IS NOT NULL -- for convenience
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
                else
                    push!(queryArgs, unique(filterValue))
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
                  _is.ref_time AS ref_time,
                  _is.carrier_contact AS carrier_contact,
                  ist.code_name AS infection_type_code_name,
                  ist.name_fr AS infection_type_name_fr,
                  ist.name_en AS infection_type_name_en")

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

        # Add some columns for the non crypted values
        if !ismissing(cryptPwd)

        end

    catch e
        rethrow(e)
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end

    totalRecords = typemax(Int64)

    if length(dfSortings) > 0
            sort!(analyse,dfSortings)
    end

    result = Dict(:rows => objects,
                  :totalRecords => totalRecords)

    return result

end
