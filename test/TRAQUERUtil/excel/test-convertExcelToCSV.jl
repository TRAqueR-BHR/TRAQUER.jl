include("__prerequisite.jl")

@testset "Test TRAQUERUtil.convertExcelToCSV" begin
    TRAQUERUtil.convertExcelToCSV(
        "test/TRAQUERUtil/excel/assets/Untitled 1.xlsx",
        "tmp/outConvertExcelToCSV.csv"
    )

    # Check that we can read the CSV file and that it has the expected content
    # col1	col2	col3
    # 1	a	2022-10-09
    # 2	b	2022-10-10
    # 3	c	2022-10-11
    df = CSV.read("tmp/outConvertExcelToCSV.csv", DataFrame)
    @test names(df) == ["col1", "col2", "col3"]
    @test df[!, "col1"] == [1, 2, 3]
    @test df[!, "col2"] == ["a", "b", "c"]
    @test df[!, "col3"] == Date.(["2022-10-09", "2022-10-10", "2022-10-11"])

end
