function CacheCtrl.setInstanceMasterKey(masterKeyHex::String)
    @info "Setting instance master key in cache: $masterKeyHex"
    CacheCtrl.set("master_key", masterKeyHex)
end
