function _TestUtils.getDefaultMasterKeyWords()
    return ["cat", "boat", "rain", "mill", "tree"]
end

function _TestUtils.getDefaultEncryptionStr()
    words = _TestUtils.getDefaultMasterKeyWords()
    return MasterKeyCtrl.generateMasterKeyFromWords(words)
end

function _TestUtils.getRandomPatient(dbconn::LibPQ.Connection)
    "SELECT * FROM patient LIMIT 1" |>
    n -> PostgresORM.execute_query_and_handle_result(n, Patient, missing, false, dbconn) |>
    first
end
