import SHA

"""
    deriveEncodedChildKey(
        parentKeyHex::String,
        saltHex::String,
        info::String,
        childKeyFormat::BinaryEncoding.BINARY_ENCODING = BinaryEncoding.hex
    )::String

Generate a child key using HKDF based on the provided parent key, salt, and info.

The derived key is returned in the specified binary format (hex or base64).
"""
function KdfChildKeyCtrl.deriveEncodedChildKey(
    parentKeyHex::String,
    saltHex::String,
    info::String,
    childKeyFormat::BinaryEncoding.BINARY_ENCODING = BinaryEncoding.hex,
    digest::String = KdfChildKeyCtrl._CHILD_KEY_DIGEST,
    keylength::Integer = KdfChildKeyCtrl._CHILD_KEY_LENGTH,
)::String

    if digest != "SHA256"
        throw(ArgumentError("unsupported child key digest: $digest"))
    end

    parent_key = TRAQUERUtil.hexToBytes(parentKeyHex)
    salt = TRAQUERUtil.hexToBytes(saltHex)
    child_key = KdfChildKeyCtrl._hkdf_sha256(parent_key, salt, info, keylength)

    if childKeyFormat == BinaryEncoding.base64
        return TRAQUERUtil.bytesToBase64(child_key)
    elseif childKeyFormat == BinaryEncoding.hex
        return TRAQUERUtil.bytesToHex(child_key)
    else
        throw(ArgumentError("unsupported child key format: $childKeyFormat. Expected 'base64' or 'hex'."))
    end

end

function KdfChildKeyCtrl._hkdf_sha256(
    key::Vector{UInt8},
    salt::Vector{UInt8},
    info::AbstractString,
    keylength::Integer,
)::Vector{UInt8}
    prk = SHA.hmac_sha256(salt, key)
    okm = UInt8[]
    previous_block = UInt8[]
    counter = UInt8(1)
    info_bytes = collect(codeunits(info))

    while length(okm) < keylength
        previous_block = SHA.hmac_sha256(
            prk,
            vcat(previous_block, info_bytes, UInt8[counter]),
        )
        append!(okm, previous_block)
        counter += UInt8(1)
    end

    return okm[1:keylength]
end
