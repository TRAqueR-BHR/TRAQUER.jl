using Test
using TimeZones
using TRAQUER
using TRAQUER.TRAQUERUtil
using TRAQUER.Controller

@test 2==2


@testset "Test TRAQUERUtil.createPartitionsIfNotExist" begin

    lastname = "Çellac"
    year = 1981
    dbconn = TRAQUERUtil.openDBConn()

    TRAQUERUtil.createPartitionsIfNotExist(lastname,
                                            year,
                                            dbconn)
    TRAQUERUtil.closeDBConn(dbconn)


end

@testset "Test TRAQUERUtil.convertStringToZonedDateTime" begin

    # Scenario '1 time entier'
    dateStr = "01/07/2020"
    timeStr = "5"
    timeZone = tz"Europe/Paris"


    # Scenario '2 out range of date '
    dateStr = "01/14/2020"
    timeStr = "2060"
    timeZone = tz"Europe/Paris"

    TRAQUERUtil.convertStringToZonedDateTime(dateStr,timeStr,timeZone)

    # Scenario '3 time entier'
    dateStr = "01/07/2020"
    timeStr = "58"
    timeZone = tz"Europe/Paris"

    TRAQUERUtil.convertStringToZonedDateTime(dateStr,timeStr,timeZone)

    # Scenario '3 time entier'
    dateStr = "01/07/2020"
    timeStr = "455"
    timeZone = tz"Europe/Paris"

    TRAQUERUtil.convertStringToZonedDateTime(dateStr,timeStr,timeZone)

    # Scenario '4 time entier'
    dateStr = "01/07/2020"
    timeStr = "2050"
    timeZone = tz"Europe/Paris"

    TRAQUERUtil.convertStringToZonedDateTime(dateStr,timeStr,timeZone)

    # Scenario '5 out range of time entier'
    dateStr = "01/07/2020"
    timeStr = "2060"
    timeZone = tz"Europe/Paris"

    TRAQUERUtil.convertStringToZonedDateTime(dateStr,timeStr,timeZone)

end


@teset "Test cleanStringForEncryptedValueCp" begin
    TRAQUERUtil.cleanStringForEncryptedValueCp("MARTIN -Abdel") == "abdel martin"
    TRAQUERUtil.cleanStringForEncryptedValueCp("b'a a") == "a a b"
end


@testset "Test src/Controller/ETL/ETL.jl" begin




    # Scenario '1 ""


     @test  ==


  end
tata = 3
@info tata

dxcare = CSV.read("csv/mouvements DXCARE 202009-202010 corrigé.csv",DataFrame)
(length ∘ unique)(dxcare.RANDOM_NOM)


timeZone = tz"Europe/Paris"

Controller.ETL.importStays(dxcare,timeZone)



inlog = DataFrame(XLSX.readtable("csv/mouvements INLOG 202009-202010 histo.xlsx"
, "mouvements INLOG 202009-202010B")...)

timeZone = tz"Europe/Paris"

Controller.ETL.importAnalysis(inlog,timeZone)
