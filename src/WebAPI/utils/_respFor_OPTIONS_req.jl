function WebAPI._respFor_OPTIONS_req()
    accessControlAllowHeaders  = "origin, content-type, accept, authorization"
    accessControlAllowHeaders *= ", $(TRAQUERUtil.getCryptPwdHttpHeaderKey())"
    accessControlAllowHeaders *= ", browser-timezone"
    accessControlAllowHeaders *= ", file_name"
    accessControlAllowHeaders *= ", exam_id"
    accessControlAllowHeaders *= ", exam_year"

    Dict(
        :headers => Dict(
            "Access-Control-Allow-Origin"      => "*",
            "Access-Control-Allow-Headers"     => accessControlAllowHeaders,
            "Access-Control-Allow-Credentials" => "true",
            "Access-Control-Allow-Methods"     => "GET, POST, PUT, DELETE, OPTIONS, HEAD",
        ),
    )
end
