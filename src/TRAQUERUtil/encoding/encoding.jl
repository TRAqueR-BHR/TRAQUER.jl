import Base64
import SHA

function TRAQUERUtil.stringToSHA256(str::AbstractString)::Vector{UInt8}
    return SHA.sha256(str)
end

function TRAQUERUtil.bytesToHex(bytes::AbstractVector{UInt8})::String
    return bytes2hex(bytes)
end

function TRAQUERUtil.hexToBytes(hex::AbstractString)::Vector{UInt8}
    # Remove all non-hexadecimal characters (like spaces, colons, etc.)
    clean_hex = replace(strip(hex), r"[^0-9A-Fa-f]" => "")

    if isempty(clean_hex)
        throw(ArgumentError("hex string must not be empty"))
    end

    if isodd(length(clean_hex))
        throw(ArgumentError("hex string must contain an even number of hexadecimal digits"))
    end

    return [parse(UInt8, clean_hex[i:i + 1]; base = 16) for i in 1:2:length(clean_hex)]
end

function TRAQUERUtil.bytesToBase64(bytes::AbstractVector{UInt8})::String
    return Base64.base64encode(bytes)
end

function TRAQUERUtil.base64ToBytes(base64::AbstractString)::Vector{UInt8}
    return Base64.base64decode(base64)
end

function TRAQUERUtil.hexToBase64(hex::AbstractString)::String
    return TRAQUERUtil.bytesToBase64(TRAQUERUtil.hexToBytes(hex))
end

function TRAQUERUtil.base64ToHex(base64::AbstractString)::String
    return TRAQUERUtil.bytesToHex(TRAQUERUtil.base64ToBytes(base64))
end

function TRAQUERUtil.stringToHex(str::AbstractString)::String
    return TRAQUERUtil.bytesToHex(collect(codeunits(str)))
end

function TRAQUERUtil.hexToString(hex::AbstractString)::String
    return String(TRAQUERUtil.hexToBytes(hex))
end

function TRAQUERUtil.stringToBase64(str::AbstractString)::String
    return TRAQUERUtil.bytesToBase64(collect(codeunits(str)))
end

function TRAQUERUtil.base64ToString(base64::AbstractString)::String
    return String(TRAQUERUtil.base64ToBytes(base64))
end
