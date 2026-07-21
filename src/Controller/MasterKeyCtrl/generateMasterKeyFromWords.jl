function MasterKeyCtrl.generateMasterKeyFromWords(masterKeyWords::Vector{String})::String
    # Convert the master key words to a hex string
    masterKeyHex = TRAQUERUtil.stringToHex(join(masterKeyWords, " "))
    return masterKeyHex
end
