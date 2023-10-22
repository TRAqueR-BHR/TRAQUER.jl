function TRAQUERUtil.formatExceptionAndStackTrace(
    ex::Exception,
    stackTrace::StackTrace,
    appuser::Union{Appuser,Missing} = missing
)

@warn "HERE1.1"
    TRAQUERUtil.formatExceptionAndStackTrace(
        ex,
        stackTrace
        ;appuser = appuser
    )

end

function TRAQUERUtil.formatExceptionAndStackTrace(
    ex::Exception,
    stackTrace::StackTrace
    ;maxLines = 20,
    stopAt = "(::Mux.",
    appuser::Union{Appuser,Missing} = missing
)

@warn "HERE1.2"
    message = ""
    if !ismissing(appuser)
        message *= "Error raised by user[$(appuser.email)]. "
    end

    message *= TRAQUERUtil.formatExceptionAndStackTraceCore(
        ex,
        stackTrace
        ;maxLines = maxLines,
        stopAt = stopAt
    )


    # No need to notify the admin for expected errors
    if ex isa CapturedException &&
        (
            ex.ex isa OutbreakNameAlreadyUsedError
        || ex.ex isa NoStayFoundError
        )
        @warn message
        return
    end

    # Log the error
    @error message

    # Notify the admins
    TRAQUERUtil.notifyAdmin(
        "Error in $(TRAQUERUtil.getInstanceCodeName())" ,
        message
    )

end

function TRAQUERUtil.formatExceptionAndStackTraceCore(
    ex::Exception,
    stackTrace::StackTrace
    ;maxLines = 20,
    stopAt = "(::Mux."
)
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

function TRAQUERUtil.formatExceptionForFrontend(ex::Exception)

    try
        if ex isa RemoteException
            TRAQUERUtil.formatExceptionForFrontend(ex.captured)
        elseif ex isa CapturedException
            TRAQUERUtil.formatExceptionForFrontend(ex.ex)
        elseif hasproperty(ex,:msg)
            ex.msg
        else
            string(ex)
        end
    catch exceptionHandlingException
        @error "Error in formatExceptionForFrontend: " exceptionHandlingException
    end

end
