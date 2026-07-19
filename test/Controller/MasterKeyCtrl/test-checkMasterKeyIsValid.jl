include("__prerequisite.jl")

@testset "Test MasterKeyCtrl.checkMasterKeyIsValid" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn

        # Check if the database is empty, if it is, create a dummy patient
        "SELECT COUNT(*) FROM patient" |>
            n -> PostgresORM.execute_plain_query(n, missing, dbconn) |>
            n -> n[1, 1] == 0 ? _TestUtils.createDummyPatient(dbconn) : nothing

        # Test with invalid/arbitrary words - should return false
        invalidWords = ["invalid", "wrong", "key", "words"]
        result = MasterKeyCtrl.checkMasterKeyIsValid(invalidWords, dbconn)
        @test result == false

        # Test with the default master key words - should return true
        defaultWords = Main.getDefaultMasterKeyWords()
        validResult = MasterKeyCtrl.checkMasterKeyIsValid(defaultWords, dbconn)
        @test validResult == true

    end

end
