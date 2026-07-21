function _TestUtils.getDefaultEncryptionStr()
    words = _TestUtils.getDefaultMasterKeyWords()
    return MasterKeyCtrl.generateMasterKeyFromWords(words)
end
