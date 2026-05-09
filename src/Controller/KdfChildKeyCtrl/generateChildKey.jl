import SHA

const _CHILD_KEY_DIGEST = "SHA256"
const _CHILD_KEY_LENGTH = 32
const _CHILD_KEY_INFO_PREFIX = "hospital-unit-file-encryption/v1/child-index="

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

function KdfChildKeyCtrl.generateChildKey(
    parentKeyHex::String,
    saltHex::String,
    ref::Int16,
    childKeyFormat::BinaryEncoding.BINARY_ENCODING = BinaryEncoding.hex,
)::String

    digest = _CHILD_KEY_DIGEST
    keylength = _CHILD_KEY_LENGTH

    if digest != "SHA256"
        throw(ArgumentError("unsupported child key digest: $digest"))
    end

    parent_key = TRAQUERUtil.hexToBytes(parentKeyHex)
    salt = TRAQUERUtil.hexToBytes(saltHex)
    info = _CHILD_KEY_INFO_PREFIX * string(ref)

    child_key = KdfChildKeyCtrl._hkdf_sha256(parent_key, salt, info, keylength)

    if childKeyFormat == BinaryEncoding.base64
        return TRAQUERUtil.bytesToBase64(child_key)
    elseif childKeyFormat == BinaryEncoding.hex
        return TRAQUERUtil.bytesToHex(child_key)
    else
        throw(ArgumentError("unsupported child key format: $childKeyFormat. Expected 'base64' or 'hex'."))
    end

end
