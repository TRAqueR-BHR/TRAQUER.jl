function CacheCtrl.getInstanceMasterKey()::Union{String, Missing}
    return CacheCtrl.get("master_key")
end
