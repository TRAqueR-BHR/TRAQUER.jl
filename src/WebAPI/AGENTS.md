# `src/WebAPI/` — agent guide

This directory implements the TRAQUER HTTP API on top of [Mux.jl](https://github.com/JuliaWeb/Mux.jl).
Everything below assumes the conventions of the repo-root `AGENTS.md` (def/imp split,
`buildSomething` vs `createSomething`, `TRAQUERUtil.openDBConn` helpers, no logging of
patient-identifying data, final newlines, etc.).

## Layout

```
src/WebAPI/
├── __def.jl            # declares build_app, serve
├── __imp.jl            # includes everything below
├── _const.jl           # JWT keyset refs + apis_paths_wo_jwt (public-path whitelist)
├── buildApp.jl         # the single file where every route is registered
├── serve.jl            # WebAPI.serve(host, port) entry point
├── utils/
│   ├── _respFor_OPTIONS_req.jl   # CORS preflight response builder
│   └── _ensure_jwt_keyset.jl     # lazy JWKSet loader (called by the JWT filter)
├── Filters/
│   ├── mux_get_appuser_from_jwt.jl   # authenticates the request, populates req[:params]
│   └── __def.jl / __imp.jl           # declares / includes the filter
└── Endpoints/
    ├── __def.jl / __imp.jl           # include every <group>/__def.jl / __imp.jl
    ├── hello-world.jl                # the only top-level (non-grouped) endpoint
    └── <group>/
        ├── __def.jl                  # one-line `function handle_<group>_<action> end`
        ├── __imp.jl                  # `include("<endpoint>.jl")` for each endpoint
        └── <endpoint>.jl             # the handler itself
```

Groups roughly mirror controller domains (`analysis`, `patient`, `stay`, `outbreak`,
`file-exchange`, `misc`, …). Keep new endpoints in an existing group when possible;
only create a new group if the controller domain really doesn't fit.

## Adding a new endpoint — the 4-place recipe

Adding an endpoint touches exactly four files. Missing any one silently breaks
either the module load or the route registration, so always do all four:

1. **Declare the handler** in `Endpoints/<group>/__def.jl`:
   ```julia
   function handle_file_exchange_download_and_process_files end
   ```
2. **Implement the handler** in `Endpoints/<group>/<endpoint>.jl` (see the skeleton
   below). One source file per endpoint function.
3. **Include it** from `Endpoints/<group>/__imp.jl`:
   ```julia
   include("get-s3-presigned-upload-url-and-kdf-child-key.jl")
   include("download-and-process-files.jl")
   ```
4. **Register the route** in `src/WebAPI/buildApp.jl`, next to the sibling routes of
   the same group:
   ```julia
   route("/api/file-exchange/download-and-process-files",
         Endpoints.handle_file_exchange_download_and_process_files),
   ```

Also consider:

- If the endpoint must be **public (no JWT required)**, add its path segments to
  `WebAPI.apis_paths_wo_jwt` in `src/WebAPI/_const.jl`. Existing entries use the
  Mux-split form (`["api", "hello"]`, `["misc", "get-current-frontend-version"]`).
- If the endpoint is **long-running**, wrap the DB work in `TRAQUERUtil.executeOnBgThread`.
- If the endpoint needs to read or write encrypted values, follow the project's
  encryption rules and use the `cryptPwd` HTTP header (see "Authentication" below).

## Handler skeleton

Nearly every handler repeats the same boilerplate. Copy this and adapt the body:

```julia
# POST /api/<group>/<action>
function WebAPI.Endpoints.handle_<group>_<action>(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/<group>/<action>"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    result  = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        ismissing(cryptPwd) && error("Missing crypt password")

        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                  JSON.parse(String(req[:data])))

        result = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                SomeCtrl.someAction(dbconn; …)   # adapt
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    responseBody = status_code == 200 ? String(JSON.json(result))
                                     : String(JSON.json(string(error)))
    Dict(
        :body    => responseBody,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
```

The response envelope must always be `Dict(:body, :headers, :status)`; the body is a
JSON-encoded `String`, never a raw Julia value.

## Request shape (what Mux hands the handler)

Mux passes a `Dict{Symbol,Any}` `req`. Keys typically available:

| key            | contents                                                       |
| -------------- | -------------------------------------------------------------- |
| `:method`      | `"GET"`, `"POST"`, `"OPTIONS"`, …                              |
| `:path`        | path split into segments (`["api", "file-exchange", "…"]`)     |
| `:uri`         | full URI as a string                                           |
| `:headers`     | vector of `Pair{String,String}` — JWT filter lowercases them   |
| `:params`      | populated by filters: `:appuser`, `:browserTimezone`, …        |
| `:data`        | raw request body as `Vector{UInt8}`                            |

The JWT filter at `Filters/mux_get_appuser_from_jwt.jl` is what fills
`req[:params][:appuser]` (and `:browserTimezone` from the `browser-timezone` header).
Handlers never have to call JWT validation themselves.

## Authentication

- **Authenticated requests** carry `Authorization: Bearer <jwt>`. The filter validates
  the token and stores the resulting `Appuser` in `req[:params][:appuser]`. Missing or
  invalid tokens short-circuit with 401 — the handler is never called.
- **Encrypted payloads** require the `cryptPwd` header (key name comes from
  `TRAQUERUtil.getCryptPwdHttpHeaderKey()`). Always read it via
  `TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)` and treat `missing` as an error:
  ```julia
  cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
  ismissing(cryptPwd) && error("Missing crypt password")
  ```
- **Public endpoints** must be listed in `WebAPI.apis_paths_wo_jwt` (see `_const.jl`)
  AND must short-circuit on `OPTIONS` themselves via `WebAPI._respFor_OPTIONS_req()`
  — the JWT filter passes OPTIONS through but does not authenticate.

## DB access

- For short calls: `TRAQUERUtil.createDBConnAndExecute() do dbconn … end`.
- For long-running work: wrap in `TRAQUERUtil.executeOnBgThread() do … end` so the
  HTTP response isn't held open:
  ```julia
  result = TRAQUERUtil.executeOnBgThread() do
      TRAQUERUtil.createDBConnAndExecute() do dbconn
          SomeCtrl.someLongAction(dbconn)
      end
  end
  ```
- For multi-statement transactions, use `TRAQUERUtil.openDBConnAndBeginTransaction()`
  and ensure the connection is closed in a `finally` block. Never leak `LibPQ.Connection`.
- Prefer controller helpers over raw SQL. Don't introduce new SQL in an endpoint.

## JSON body parsing

Body parsing convention used across the codebase:

```julia
obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
          JSON.parse(String(req[:data])))
```

- This converts `nothing` JSON values into Julia `missing` so the rest of the code
  can use `ismissing`, `passmissing`, etc. consistently.
- For typed structs, use `PostgresORM.json2entity(SomeEntity, obj["key"])`.
- For vectors, `JSON.parse` returns `Vector{Any}`. Convert explicitly when the
  controller signature demands `Vector{T}`:
  ```julia
  fileURLs = convert(Vector{String}, obj["fileURLs"])
  ```

## Naming

| thing               | convention                                                      |
| ------------------- | --------------------------------------------------------------- |
| Route path segments | kebab-case: `/api/file-exchange/download-and-process-files`     |
| Handler function    | `handle_<group>_<action>` in `WebAPI.Endpoints`, snake_case     |
| Controller function | `SomeCtrl.someAction` (camelCase, one source file per function) |
| Source files        | kebab-case `<action>.jl`, one file per endpoint                  |

## Testing

- Tests live under `test/WebAPI/Endpoints/<group>/test-<endpoint>.jl`.
- They call the handler **directly** with a hand-built `Dict{Symbol,Any}` rather than
  hitting the HTTP server:
  ```julia
  req = Dict{Symbol,Any}(
      :method => "POST",
      :params => Dict{Symbol,Any}(:appuser => missing),
      :data   => UInt8[],
  )
  response = TRAQUER.WebAPI.Endpoints.handle_file_exchange_…(req)
  ```
- Each group directory needs a `__prerequisite.jl` that pulls in the shared
  `test/runtests-prerequisite.jl`:
  ```julia
  include("../../../runtests-prerequisite.jl")
  ```
- Use `TRAQUERUtil.createDBConnAndExecute()` inside the test for any DB assertions
  or cleanup (see `test/WebAPI/Endpoints/file-exchange/test-get-s3-presigned-upload-url-and-kdf-child-key.jl`
  for a working example).
- Common helpers (dummy patients, units, infectious statuses, …) are in
  `test/_TestUtils/` and loaded by `runtests-prerequisite.jl`; use them instead of
  duplicating setup.

## Style reminders

- Final newline on every file.
- One source file per handler / controller function.
- Don't log patient-identifying data, decrypted values, tokens, passwords, or keys.
- Don't add new endpoints directly under `Endpoints/<file>.jl`; group them.
- Don't drop scheduled or auth logic to disable an endpoint — instead, blacklist it
  via config or extend `apis_paths_wo_jwt` deliberately.

## Safety checklist before finishing

- All 4 registration files updated for a new endpoint (`__def.jl`, `<endpoint>.jl`,
  `__imp.jl`, `buildApp.jl`).
- `apis_paths_wo_jwt` updated if the endpoint is public.
- Targeted test added/updated under `test/WebAPI/Endpoints/<group>/`.
- No sensitive values logged or echoed in error responses.
- `julia --project` parses all touched files (use `Meta.parse(read(path, String))`).
