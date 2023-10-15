function ExposedFunctionCtrl.execute(
    exposedFunction::ExposedFunction,
    arguments::Vector{ExposedFunctionArgument},
    appuser::Appuser,
    cryptPwd::String
)

    @spawn TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
        ExposedFunctionCtrl.execute(
            exposedFunction,
            arguments,
            appuser,
            cryptPwd,
            dbconn
        )
    end

    return true

end

function ExposedFunctionCtrl.execute(
    exposedFunction::ExposedFunction,
    arguments::Vector{ExposedFunctionArgument},
    appuser::Appuser,
    cryptPwd::String,
    dbconn::LibPQ.Connection
)

    fct = TRAQUERUtil.getJuliaFunction(exposedFunction)
    values = []

    for arg in arguments
        if arg.isDatabaseCryptPwd === true
            push!(values, cryptPwd)
        elseif arg.isCurrentUser === true
            push!(values, appuser)
        elseif arg.juliaTypeName == "LibPQ.Connection"
            push!(values, dbconn)
        elseif arg.juliaTypeName ∈ ["Dates.Date","Date"]
            convertedValue = ZonedDateTime(arg.value) |>
            n -> astimezone(n, TRAQUERUtil.getTimezone()) |> Date
            push!(values, convertedValue)
        else
            convertedValue = VariableValueCtrl.convertDecryptStringToActualType(
                arg.value,
                TRAQUERUtil.string2type(arg.juliaTypeName),
                dbconn
            )
            push!(values, convertedValue)
        end
    end

    fct(values...)

    true
end
