include("__prerequisite.jl")

# Integration test for ExceptionCtrl.logExceptionAndNotifyAdmin.
#
# This is intentionally simple: the function has real side effects (it logs
# via @error and calls NotificationCtrl.notifyAdmin which tries Slack and
# email). Rather than mocking these, we capture the @error log entry to
# verify the message format and let the Slack/email side effects run as
# they would in production — they are wrapped in their own try/catch so
# transient failures do not propagate.
#
# NOTE: passing an appuser is not exercised here because
# logExceptionAndNotifyAdmin currently accesses `appuser.phone`, a field
# that does not exist on the current `Appuser` struct. That looks like a
# pre-existing bug in the production code; once `phone` is added (or the
# access removed) this test can be extended with an appuser case.

@testset "Test ExceptionCtrl.logExceptionAndNotifyAdmin" begin

    err = ErrorException("intentional test error")
    trace = stacktrace(catch_backtrace())

    # Capture @error log records emitted during the call.
    captured = IOBuffer()
    Logging.with_logger(Logging.SimpleLogger(captured, Logging.Error)) do
        # No appuser, default canNotifyAdminByEmail=true.
        ExceptionCtrl.logExceptionAndNotifyAdmin(err, trace)

        # Explicit canNotifyAdminByEmail=false should not change the
        # message body, only the downstream notification call.
        ExceptionCtrl.logExceptionAndNotifyAdmin(
            err,
            trace;
            canNotifyAdminByEmail = false,
        )
    end

    log_output = String(take!(captured))

    # Each call logs the exception message via @error.
    @test occursin("intentional test error", log_output)
    # The function is not given an appuser, so the message should never
    # include the "Error raised by user[…]" prefix.
    @test !occursin("Error raised by user", log_output)

end