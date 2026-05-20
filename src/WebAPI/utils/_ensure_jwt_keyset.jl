function WebAPI._ensure_jwt_keyset()
    if isnothing(WebAPI._jwtkeyset[])
        ks = JWKSet(Conf.getConf("security", "jwt_signing_keys_uri"))
        refresh!(ks)
        WebAPI._jwtkeyset[] = ks
        WebAPI._jwtkeyid[]  = first(first(ks.keys))
    end
    return WebAPI._jwtkeyset[], WebAPI._jwtkeyid[]
end
