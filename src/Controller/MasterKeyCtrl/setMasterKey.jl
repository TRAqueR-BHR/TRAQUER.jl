function MasterKeyCtrl.setMasterKey(masterKeyWords::Vector{String})::Bool
    dbconn = TRAQUERUtil.openDBConn()
    try
        # Check the master key is valid by attempting to decrypt a known value from the database
        if !MasterKeyCtrl.checkMasterKeyIsValid(masterKeyWords, dbconn)
            return false
        end
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end

    # Convert words to hex and store in cache
    masterKeyHex = TRAQUERUtil.stringToHex(join(masterKeyWords, " "))
    CacheCtrl.setInstanceMasterKey(masterKeyHex)
    return true
end
