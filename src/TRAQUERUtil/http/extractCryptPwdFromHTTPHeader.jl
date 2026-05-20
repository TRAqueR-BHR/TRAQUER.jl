function TRAQUERUtil.extractCryptPwdFromHTTPHeader(req::Dict{Any,Any})
    headersDict = Dict(zip(lowercase.(getproperty.(req[:headers], :first)),
                                  getproperty.(req[:headers], :second)))
    cryptPwdHttpHeaderKey = TRAQUERUtil.getCryptPwdHttpHeaderKey()
    cryptPwd = if haskey(headersDict,cryptPwdHttpHeaderKey)
        string(headersDict[cryptPwdHttpHeaderKey])
    else
        missing
    end

    return cryptPwd
end
