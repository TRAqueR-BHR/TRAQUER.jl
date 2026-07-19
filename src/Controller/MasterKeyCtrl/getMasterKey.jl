function MasterKeyCtrl.getMasterKey()::Union{String, Missing}
    CacheCtrl.getInstanceMasterKey()
end
