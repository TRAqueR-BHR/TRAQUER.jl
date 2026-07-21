function MasterKeyCtrl.getMasterKey(;failIfMissing::Bool = false)::Union{String, Missing}
    crypPwd = CacheCtrl.getInstanceMasterKey()
    if ismissing(crypPwd) && failIfMissing
        error("Master key is not set")
    end
    return crypPwd
end
