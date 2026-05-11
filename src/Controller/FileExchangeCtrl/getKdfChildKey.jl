function FileExchangeCtrl.getKdfChildKey(
    dbconn
)::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}}

    info_prefix = "file-exchange"
    ttl = Hour(24) # Time to live for the child key, after which it should no longer be used for new encryptions

    KdfChildKeyCtrl.generateAndSerializeChildKey(
        info_prefix,
        ttl,
        dbconn,
    )

end
