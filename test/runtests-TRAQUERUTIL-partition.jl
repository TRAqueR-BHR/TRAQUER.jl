@testset "Test TRAQUERUtil.createTablesPartitionsOnYearMonthForLastYears" begin

        TRAQUERUtil.createTablesPartitionsOnYearMonthForLastYears()
end

schemaName = "public"
tableName = "stay"
year = 2021
month = 2
dbconn = TRAQUERUtil.openDBConn()


TRAQUERUtil.createTablePartitionOnYearMonth(schemaName,
                                          tableName,
                                          year,
                                          month,
                                          dbconn)


schemaName = "public"
tableName = "analysis"
year = 2021
month = 1
dbconn = TRAQUERUtil.openDBConn()
TRAQUERUtil.createTablePartitionOnYearMonth(schemaName,
                                        tableName,
                                        year,
                                        month,
                                        dbconn)
