function TRAQUERUtil.createPartitionPatientBirthdateIfNotExist(birthdate::Date,
                                                               dbconn::LibPQ.Connection)


        _year = Dates.year(birthdate)
         #
         # Create partition for 'patient_birthdate_crypt'
         #
         partitionedTable = "patient_birthdate_crypt"
         partitionName = "$(partitionedTable)_$(_year)"
         schema = "public"
         # If partition does not exist, create it
         if !PostgresORM.SchemaInfo.check_if_table_or_partition_exists(
             partitionName,
             schema,
             dbconn)

             @info "Create partition[$schema.$partitionName]"

             queryStr =
                 "CREATE TABLE $schema.$partitionName
                    PARTITION OF $schema.$partitionedTable
                    FOR VALUES IN ($(_year));"

             preparedQuery = LibPQ.prepare(dbconn, queryStr)

             # Prepare the query aruments
             queryResult = execute(preparedQuery,
                                    []
                                   ;throw_error=true)

          end
end

function TRAQUERUtil.createPartitionPatientNameIfNotExist(lastname::AbstractString,
                                                          dbconn::LibPQ.Connection)

        #
        # Create partition for 'patient_name_crypt'
        #
        lastnameLowerCaseNoAccent = TRAQUERUtil.cleanStringForEncryptedValueCp(lastname)
        firstLetter = lastnameLowerCaseNoAccent[1]
        partitionedTable = "patient_name_crypt"
        partitionName = "$(partitionedTable)_$(firstLetter)"
        schema = "public"
        # If partition does not exist, create it
        if !PostgresORM.SchemaInfo.check_if_table_or_partition_exists(
            partitionName,
            schema,
            dbconn)

            @info "Create partition[$schema.$partitionName]"

            queryStr =
                "CREATE TABLE $schema.$partitionName
                   PARTITION OF $schema.$partitionedTable
                   FOR VALUES IN ('$firstLetter');"

            preparedQuery = LibPQ.prepare(dbconn, queryStr)

            # Prepare the query aruments
            queryResult = execute(preparedQuery,
                                   []
                                  ;throw_error=true)

         end
end

function TRAQUERUtil.createPartitionPatientRefIfNotExist(ref::AbstractString,
                                                         dbconn::LibPQ.Connection)

        #
        # Create partition for 'patient_ref_crypt'
        #
        oneChar = PatientCtrl.getRefOneChar(ref)
        partitionedTable = "patient_ref_crypt"
        partitionName = "$(partitionedTable)_$(oneChar)"
        schema = "public"
        # If partition does not exist, create it
        if !PostgresORM.SchemaInfo.check_if_table_or_partition_exists(
            partitionName,
            schema,
            dbconn)

            @info "Create partition[$schema.$partitionName]"

            queryStr =
                "CREATE TABLE $schema.$partitionName
                   PARTITION OF $schema.$partitionedTable
                   FOR VALUES IN ('$oneChar');"

            preparedQuery = LibPQ.prepare(dbconn, queryStr)

            # Prepare the query aruments
            queryResult = execute(preparedQuery,
                                   []
                                  ;throw_error=true)

         end
end

function TRAQUERUtil.getTablePartitionNameOnYearMonth(tableName::AbstractString,
                                       year::Integer,
                                       month::Integer)
    # Add the trailing 0 if the month is inferior to 10
    monthStr = lpad(month,2,"0")
    partitionTable = "$(tableName)_$(year)$(monthStr)"

    return partitionTable
end

function TRAQUERUtil.createTablesPartitionsOnYearMonthForLastYears()

  _tables = [("public","stay"),
            ("public","analysis")]

  dbconn = TRAQUERUtil.openDBConn()

  rollbackYears = 0 # >= 0

  currentYear = Dates.year(today())
  for i in 0:rollbackYears
     _year = currentYear - i
     for _table in _tables
         schemaName = first(_table)
         tableName = last(_table)
         TRAQUERUtil.createTablePartitionsOnYearMonthForGivenYear(schemaName,
                                                                  tableName,
                                                                  _year,
                                                                  dbconn)
     end
  end

  TRAQUERUtil.closeDBConn(dbconn)


end


function TRAQUERUtil.createTablePartitionsOnYearMonthForGivenYear(schemaName::AbstractString,
                                                                  tableName::AbstractString,
                                                                  _year::Integer,
                                                                  dbconn::LibPQ.Connection)

  for _month in 1:12
      TRAQUERUtil.createTablePartitionOnYearMonth(schemaName,
                                                  tableName,
                                                  _year,
                                                  _month,
                                                  dbconn)
  end

end

function TRAQUERUtil.createTablePartitionOnYearMonth(schemaName::AbstractString,
                                          tableName::AbstractString,
                                          year::Integer,
                                          month::Integer,
                                          dbconn::LibPQ.Connection)

    parentTableNameWithSchema = "$(schemaName).$(tableName)"

    partitionTable = TRAQUERUtil.getTablePartitionNameOnYearMonth(tableName,
                                                       year,
                                                       month)


    # Vérifie que la partition n'existe pas déjà
    if PostgresORM.SchemaInfo.check_if_table_or_partition_exists(
        partitionTable,
        schemaName,
        dbconn
    )
        return
    end

    # When executing an integration task on several workers it is possible that two workers
    # detect that a partition is missing, which results in the two workers trying to create
    # a partition and one worker will fail at doing it, an error will be thrown we will need
    # to reintegrate the line where the integration process failed.
    # Therefore if the partition does not exist we introduce a random delay and chek again
    sleep(rand()*2) # between 0 and 2 seconds
    if PostgresORM.SchemaInfo.check_if_table_or_partition_exists(
        partitionTable,
        schemaName,
        dbconn
    )
        return
    end


    # Définie les bornes de la partition
    startDate = Dates.Date(year,month,01)
    endDate = startDate + Month(1)
    queryArgs = []

    result::Int64 = 0
    try
         queryString = "CREATE TABLE $schemaName.$partitionTable
                         PARTITION OF $parentTableNameWithSchema
                         FOR VALUES FROM ('$startDate') TO ('$endDate')"

         preparedQuery = LibPQ.prepare(dbconn,
                                       queryString)

         # Prepare the query aruments
         queryResult = execute(preparedQuery,
                                queryArgs
                               ;throw_error=true)

         # Return the number of rows inserted
         # result = LibPQ.num_affected_rows(queryResult)


    catch e
        rethrow(e)
    end
end

function TRAQUERUtil.createPartitionStayIfNotExist(stay::Stay,
                                                   dbconn::LibPQ.Connection)

    schemaName = "public"
    tableName = "stay"
    year = Dates.year(stay.inDate)
    month = Dates.month(stay.inDate)
    TRAQUERUtil.createTablePartitionOnYearMonth(schemaName,
                                                tableName,
                                                year,
                                                month,
                                                dbconn)

end

function TRAQUERUtil.createPartitionContactExposureIfNotExist(
    contactExposure::ContactExposure, dbconn::LibPQ.Connection)

    schemaName = "public"
    tableName = "contact_exposure"
    year = Dates.year(contactExposure.startTime)
    month = Dates.month(contactExposure.startTime)
    TRAQUERUtil.createTablePartitionOnYearMonth(schemaName,
                                                tableName,
                                                year,
                                                month,
                                                dbconn)

end

function TRAQUERUtil.createPartitionAnalysisRefIfNotExist(ref::AbstractString,
                                                          dbconn::LibPQ.Connection)

        #
        # Create partition for 'analyses_ref_crypt'
        #
        oneChar = AnalysisResultCtrl.getRefOneChar(ref)
        partitionedTable = "analysis_ref_crypt"
        partitionName = "$(partitionedTable)_$(oneChar)"
        schema = "public"
        # If partition does not exist, create it
        if !PostgresORM.SchemaInfo.check_if_table_or_partition_exists(
            partitionName,
            schema,
            dbconn)

            @info "Create partition[$schema.$partitionName]"

            queryStr =
                "CREATE TABLE $schema.$partitionName
                   PARTITION OF $schema.$partitionedTable
                   FOR VALUES IN ('$oneChar');"

            preparedQuery = LibPQ.prepare(dbconn, queryStr)

            # Prepare the query aruments
            queryResult = execute(preparedQuery,
                                   []
                                  ;throw_error=true)

         end
end
