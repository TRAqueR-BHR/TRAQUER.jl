include("__prerequisite.jl")

@testset "Test CacheCtrl.getInstanceMasterKey calls CacheCtrl.get with 'master_key'" begin

    # getInstanceMasterKey calls CacheCtrl.get("master_key") and returns the result.
    # The current stub implementation of CacheCtrl.get returns bytes2hex(SHA.sha256("cat boat rain")).
    result = CacheCtrl.getInstanceMasterKey()


end
