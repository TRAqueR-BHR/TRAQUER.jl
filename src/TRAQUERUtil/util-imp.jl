# see ~/.julia/config/startup.jl for setting the environment variable
function TRAQUERUtil.loadConf()::ConfParse

    environment_variable_name = "TRAQUER_CONFIGURATION_FILE"

    if haskey(ENV,environment_variable_name)
        @info "loading configuration file[$(ENV[environment_variable_name])]"
        conf_file = ENV[environment_variable_name]
    else
        throw(DomainError("The application requires the environment"
                          * " variable[$environment_variable_name] to be set."))
    end

    conf = ConfParse(conf_file)
    parse_conf!(conf)
    return(conf)

end

function TRAQUERUtil.hasConf(category_name::String,property_name::String)
    ConfParser.haskey(TRAQUER.config,
                        category_name,
                        property_name)
end

function TRAQUERUtil.getConf(category_name::String,property_name::String)
    ConfParser.retrieve(TRAQUER.config,
                        category_name,
                        property_name)
end

function TRAQUERUtil.getTimezoneAsStr()
    TRAQUERUtil.getConf("default","timezone")
end

function TRAQUERUtil.getTimezone()
    TimeZones.TimeZone(TRAQUERUtil.getTimezoneAsStr())
end

function TRAQUERUtil.getOrganizationCustomModuleName()
    TRAQUERUtil.getConf("custom","module_name")
end

function TRAQUERUtil.getOrganizationCustomModule()
    moduleName = TRAQUERUtil.getOrganizationCustomModuleName()
    if moduleName == "CHTNoumea"
        return Custom.CHTNoumea
    elseif moduleName == "CHUBrest"
        return Custom.CHUBrest
    elseif moduleName == "Demo"
        return Custom.Demo
    else
        error("Missing module[$moduleName]")
    end
end


"""

    updateConf()::Bool

Update Medilegist.translation singleton

"""
function TRAQUERUtil.updateConf()::Bool

    # NOTE: It would be easier to do `parse_conf!(Medilegist.translation)` but this errors
    #        with SystemError: seek: Illegal seek
    conf = TRAQUERUtil.loadConf()
    ConfParser.merge!(TRAQUER.config,conf)

end

function TRAQUERUtil.openDBConn()
    database = TRAQUERUtil.getConf("database","database")
    user = TRAQUERUtil.getConf("database","user")
    host = TRAQUERUtil.getConf("database","host")
    port = TRAQUERUtil.getConf("database","port")
    password = TRAQUERUtil.getConf("database","password")

    conn = LibPQ.Connection("host=$(host)
                             port=$(port)
                             dbname=$(database)
                             user=$(user)
                             password=$(password)
                             "; throw_error=true)

    execute(conn, "SET enable_partition_pruning = on;")
    execute(conn, "SET TIMEZONE='$(TRAQUERUtil.getTimezoneAsStr())';")

    return conn
end

function TRAQUERUtil.openDBConnAndBeginTransaction()
    conn = TRAQUERUtil.openDBConn()
    TRAQUERUtil.beginDBTransaction(conn)
    return conn
end

function TRAQUERUtil.beginDBTransaction(conn)
    execute(conn, "BEGIN;")
end

function TRAQUERUtil.commitDBTransaction(conn)
    execute(conn, "COMMIT;")
end

function TRAQUERUtil.rollbackDBTransaction(conn)
    execute(conn, "ROLLBACK;")
end

function TRAQUERUtil.closeDBConn(conn)
    close(conn)
end

function TRAQUERUtil.getInstanceCodeName()
    TRAQUERUtil.getConf("default","instance_code_name")
end

function TRAQUERUtil.getCryptPwdHttpHeaderKey()
    return "crypt_pwd"
end

function TRAQUERUtil.extractCryptPwdFromHTTPRequest(req::Dict{Any,Any})
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



function TRAQUERUtil.convertStringToZonedDateTime(dateStr::String,
                                    timeStr::String,
                                    _tz::VariableTimeZone)

               dateDate = Date(dateStr,DateFormat("d/m/y"))
               timeTime = begin

                  timeTemp = missing

                  if length(timeStr) == 1
                     timeTemp = Time(timeStr, DateFormat("M"))
                  end

                  if length(timeStr) == 2
                     timeTemp = Time(timeStr, DateFormat("MM"))
                  end


                  if length(timeStr) == 3
                     timeTemp = Time(timeStr, DateFormat("HMM"))
                  end

                  if length(timeStr) == 4
                     timeTemp = Time(timeStr, DateFormat("HHMM"))
                  end
                  if length(timeStr) == 5
                     timeTemp = Time(timeStr, DateFormat("HH:MM"))
                  end
                  timeTemp

               end



               dateTimes = DateTime(dateDate,timeTime)


               inDateTest =  TimeZones.first_valid(dateTimes,_tz)

               return  inDateTest
end


function TRAQUERUtil.rmAccentsAndLowercase(str::String)
    return Unicode.normalize(str,stripmark=true) |>
           n -> lowercase(n)
end


function TRAQUERUtil.cleanStringForEncryptedValueCp(str)
    result = TRAQUERUtil.rmAccentsAndLowercase(str) |>
             n -> TRAQUERUtil.normalizeWhites(n,
                                             # replace line returns by spaces
                                             true) |>
             n -> split(n,r"[[:punct:]\s]") |>
             n -> filter(x -> !isempty(x),n) |>
             n -> sort(n) |>
             n -> string.(n) |>
             n -> join(n," ")
    result
end


function TRAQUERUtil.normalizeWhites(str::String, keepLineReturns::Bool)

    if keepLineReturns
        result = TRAQUERUtil.removeDoubleSpaces(str) |>
                 n -> TRAQUERUtil.removeDoubleLineReturns(n)
    else
        result = replace(str, r"\s" => " ") |> # Replace all spaces (including line
                                                  #   returns) by a space
                 n -> TRAQUERUtil.removeDoubleSpaces(n)
    end

    return result
end

"""
NOTE: Do not use "\\s" because this would also remove the line returns
      also do not use \\v (supposedly a tab) because it also removes the line returns
"""
function TRAQUERUtil.removeDoubleSpaces(str)

    result = str |> n -> replace(n, r"\u00a0" => " ") |> # Replace NBSP by a normal space
                    n -> replace(n,r"[\ \f\t]{2,}" => " ") |>
                    n -> (string∘strip)(n)
    return result
end

"""
NOTE: Also clean the whites around the line return
"""
function TRAQUERUtil.removeDoubleLineReturns(str)
    result = str |> n -> replace(n,r"[\ \f\t\n]*[\n\r]+[\ \f\t\n]*" => "\n") |>
                    n -> (string∘strip)(n)
    return result
end


function TRAQUERUtil.formatExceptionAndStackTrace(ex::Exception,
                          stackTrace::StackTrace
                          ;maxLines = 20,
                           stopAt = "(::getfield(Mux")
    message = TRAQUERUtil.formatExceptionAndStackTraceCore(ex,
                              stackTrace
                              ;maxLines = maxLines,
                               stopAt = stopAt)
    @error message
end

# TODO: We should manage to specify that the datatype is an Enum
function TRAQUERUtil.listEnums(enumType::DataType
                          ;appuser::Appuser)

    tupleOfEnums = instances(enumType)

    return [tupleOfEnums...]
end

function TRAQUERUtil.formatExceptionAndStackTraceCore(ex::Exception,
                          stackTrace::StackTrace
                          ;maxLines = 20,
                           stopAt = "(::getfield(Mux")
    # @info length(stackTrace)
    message = string(ex)
    counter = 0
    for stackFrame in stackTrace
        counter += 1
        if counter > maxLines
            break
        end
        stackFrameAsStr = string(stackFrame)
        if occursin(stopAt,stackFrameAsStr)
            break
        end
        message *= "\n" * string(stackFrame)
    end
    message
end

function TRAQUERUtil.blindBakeIsRequired()
    return parse(Bool,getConf("default","blind_bake"))
end

function TRAQUERUtil.string2enum(enumType::DataType, str::String)
    PostgresORM.PostgresORMUtil.string2enum(enumType, str)
end

function TRAQUERUtil.string2enum(enumType::DataType, str::Missing)
    return missing
end


function TRAQUERUtil.initialize_http_response_status_code(req)
    # The status code is by default 200 and we look if a filter wants
    #   to overwrite it
    status_code = 200
    if (haskey(req,:params)
        && haskey(req[:params],:status))
         status_code = req[:params][:status]
     end
     return status_code
end


function TRAQUERUtil.getCurrentFrontendVersion()

    dbconn = TRAQUERUtil.openDBConn()
    result = try
        query_string =
           "SELECT * FROM misc.frontend_version
            ORDER BY name DESC
            LIMIT 1
            "
        result = PostgresORM.
            execute_query_and_handle_result(query_string,
                                            FrontendVersion,
                                            [], # query_args
                                            false, # retrieve_complex_props
                                            dbconn)
        result
    catch e
        rethrow(e)
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end

    if isempty(result)
        return missing
    end

    return result[1]

end

function TRAQUERUtil.json2Entity(datatype::DataType,
                     dict::Dict{String,Any})
    dict = PostgresORM.PostgresORMUtil.dictstringkeys2symbol(dict)
    dict = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(dict)
    PostgresORM.Controller.util_dict2entity(
        dict,
        datatype,
        false, # building_from_database_result::Bool,
        false, # retrieve_complex_props::Bool,
        missing #dbconn::Union{LibPQ.Connection,Missing}
             )
end