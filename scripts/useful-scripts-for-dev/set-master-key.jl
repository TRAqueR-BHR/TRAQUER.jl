include("__prerequisite.jl")

defaultWords = _TestUtils.getDefaultMasterKeyWords()
validResult = MasterKeyCtrl.setMasterKey(defaultWords)
