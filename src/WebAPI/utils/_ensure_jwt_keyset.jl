function WebAPI._ensure_jwt_keyset()
    if isnothing(_jwtkeyset[])
        ks = JWKSet(TRAQUERUtil.getConf("security", "jwt_signing_keys_uri"))
        refresh!(ks)
        _jwtkeyset[] = ks
        _jwtkeyid[]  = first(first(ks.keys))
    end
    return _jwtkeyset[], _jwtkeyid[]
end
