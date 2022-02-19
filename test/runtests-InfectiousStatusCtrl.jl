@testset "Test InfectiousStatusCtrl.generateCarrierStatusesForEPC" begin
    dbconn = TRAQUERUtil.openDBConn()
    InfectiousStatusCtrl.generateCarrierStatusesForEPC(Date("2020-01-01"),
                                                 dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end


@testset "Test InfectiousStatusCtrl.generateContactExposures" begin
    dbconn = TRAQUERUtil.openDBConn()
    infectiousStatus =
        PostgresORM.retrieve_one_entity(InfectiousStatus(id = "af6753a1-2af9-4223-b412-124e7919eb6c"),
                                        false,
                                        dbconn)

    contactStays = InfectiousStatusCtrl.generateContactExposures(infectiousStatus,
                                                  dbconn)

    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test InfectiousStatusCtrl.getInfectiousStatusForListing" begin
    df = InfectiousStatusCtrl.getInfectiousStatusForListing(
                5,
                1,
                Vector{Dict{String,Any}}()
                ;cryptPwd = missing)[:rows]

    println(df)

    df = InfectiousStatusCtrl.getInfectiousStatusForListing(
                5,
                1,
                Vector{Dict{String,Any}}()
                ;cryptPwd = getDefaultEncryptionStr())[:rows]


    println(df)
end
