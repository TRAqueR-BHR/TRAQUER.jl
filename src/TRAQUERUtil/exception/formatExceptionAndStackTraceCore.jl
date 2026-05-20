function TRAQUERUtil.formatExceptionAndStackTraceCore(ex::Exception,
                          stackTrace::StackTrace
                          ;maxLines = 20,
                           stopAt = "Mux.")
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
