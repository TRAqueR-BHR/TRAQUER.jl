"""
Registry of child keys derived from the unit master key and used for cryptographic
    operations. Each child key has its own salt.
"""
mutable struct KdfChildKey <: IKdfChildKey

  id::Union{Missing,String}

  # Length of the derived key in bytes used in the key derivation function.
  keyLength::Union{Missing,Int16}

  # Timestamp when the child key allocation entry was created.
  createdAt::Union{Missing,ZonedDateTime}

  # Timestamp after which the child key should no longer be used for new encryptions. Existing
  # encrypted files remain decryptable.
  expiresAt::Union{Missing,ZonedDateTime}

  # Digest algorithm used in the key derivation function (eg. SHA256).
  digest::Union{Missing,String}

  saltValue::Union{Missing,String} # Salt value

  # HKDF context/application-specific information used to derive the child key.
  info::Union{Missing,String}

  # Child key reference stored alongside data encrypted with this key
  ref::Union{Missing,Int32}

  KdfChildKey(args::NamedTuple) = KdfChildKey(;args...)
  KdfChildKey(;
    id = missing,
    keyLength = missing,
    createdAt = missing,
    expiresAt = missing,
    digest = missing,
    saltValue = missing,
    info = missing,
    ref = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.keyLength = keyLength
    x.createdAt = createdAt
    x.expiresAt = expiresAt
    x.digest = digest
    x.saltValue = saltValue
    x.info = info
    x.ref = ref
    return x
  end

end
