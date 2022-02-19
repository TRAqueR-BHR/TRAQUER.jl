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
             TRAQUERUtil.commitDBTransaction(dbconn)

          end
end

function TRAQUERUtil.createPartitionPatientNameIfNotExist(lastname::String,
                                                          dbconn::LibPQ.Connection)

        #
        # Create partition for 'patient_name_crypt'
        #
        lastnameLowerCaseNoAccent = TRAQUERUtil.rmAccentsAndLowercase(lastname)
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
            TRAQUERUtil.commitDBTransaction(dbconn)

         end
end

function TRAQUERUtil.createPartitionPatientRefIfNotExist(ref::String,
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
            TRAQUERUtil.commitDBTransaction(dbconn)

         end
end

function TRAQUERUtil.getTablePartitionNameOnYearMonth(tableName::String,
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


function TRAQUERUtil.createTablePartitionsOnYearMonthForGivenYear(schemaName::String,
                                                                  tableName::String,
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

function TRAQUERUtil.createTablePartitionOnYearMonth(schemaName::String,
                                          tableName::String,
                                          year::Integer,
                                          month::Integer,
                                          dbconn::LibPQ.Connection)

    parentTableNameWithSchema = "$(schemaName).$(tableName)"

    partitionTable = TRAQUERUtil.getTablePartitionNameOnYearMonth(tableName,
                                                       year,
                                                       month)

    @info "Create partition $schemaName.$partitionTable"

    # Vérifie que la partition n'existe pas déjà
    if PostgresORM.SchemaInfo.check_if_table_or_partition_exists(
                                    partitionTable,
                                    schemaName,
                                    dbconn)
        @info "Partition $schemaName.$partitionTable already exists"
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

function TRAQUERUtil.createPartitionAnalysisIfNotExist(analysis::Analysis,
                                                       dbconn::LibPQ.Connection)

    schemaName = "public"
    tableName = "analysis"
    year = Dates.year(analysis.stay.inDate)
    month = Dates.month(analysis.stay.inDate)
    TRAQUERUtil.createTablePartitionOnYearMonth(schemaName,
                                                tableName,
                                                year,
                                                month,
                                                dbconn)

end

function TRAQUERUtil.createPartitionAnalysisRefIfNotExist(ref::String,
                                                          dbconn::LibPQ.Connection)

        #
        # Create partition for 'analyses_ref_crypt'
        #
        oneChar = AnalysisCtrl.getRefOneChar(ref)
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
            TRAQUERUtil.commitDBTransaction(dbconn)

         end
end
