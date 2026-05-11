function KdfChildKeyCtrl.generateAndSerializeChildKey(
    infoPrefix::String,
    dbconn::LibPQ.Connection,
)::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}}

end

function KdfChildKeyCtrl.generateAndSerializeChildKey(
    parentKeyHex::String,
    infoPrefix::String,
    dbconn::LibPQ.Connection,
)::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}}

end
