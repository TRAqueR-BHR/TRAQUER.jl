function ExceptionCtrl.logExceptionAndNotifyAdmin(
    ex::Exception,
    stackTrace::StackTrace,
    appuser::Union{Appuser,Missing} = missing
    ;maxLines = 20,
    stopAt = "(::Mux.",
    canNotifyAdminByEmail::Bool = true
)

    message = ""
    if !ismissing(appuser)
        message *= "Error raised by user[$(appuser.email)]"
        message *= ". "
    end

    message *= ExceptionCtrl.formatExceptionAndStackTrace(
        ex,
        stackTrace
        ;maxLines = maxLines,
        stopAt = stopAt
    )


    # No need to notify the admin for expected errors
    # if ex isa CapturedException && ex.ex isa CannotMoveExamToAnotherYearError
    #     @warn message
    #     return
    # end

    # Log the error
    @error message

    # Notify the admins
    NotificationCtrl.notifyAdmin(
        "Error in $(Conf.getInstanceCodeName())" ,
        message
        ;canNotifyAdminByEmail = canNotifyAdminByEmail
    )

end
