"""
    get(key::String)::String
Retrieve a value from the cache based on the provided key.
"""
function CacheCtrl.get(key::String)::String

    # Temporary implementation for testing purposes, it should actually retrieve the value
    # from redis
    return bytes2hex(SHA.sha256("cat boat rain"))
end
