include("__prerequisite.jl")

@testset "Test ExceptionCtrl.formatExceptionAndStackTrace" begin

    # Build a real exception + stack trace by raising one inside a helper.
    # The Base `error` call produces a deterministic frame at `error.jl` we
    # can pattern-match against without depending on file paths or gensym
    # numbers (Julia 1.10 only emits the file basename in stack frames).
    err, trace = try
        error("intentional test error")
    catch e
        (e, stacktrace(catch_backtrace()))
    end

    # Basic case: message is a String containing the exception text and
    # at least one frame. We assert against "error.jl" because the
    # `error(...)` call site is always in the Base library, so the pattern
    # is stable across Julia versions and execution paths.
    msg = ExceptionCtrl.formatExceptionAndStackTrace(err, trace)
    @test msg isa AbstractString
    @test occursin("intentional test error", msg)
    @test occursin("error.jl", msg)

    # maxLines=0: counter starts at 0, increments to 1, immediately exceeds,
    # so no stack frames are appended. The exception text is still there.
    msg_no_frames = ExceptionCtrl.formatExceptionAndStackTrace(
        err, trace; maxLines = 0
    )
    @test occursin("intentional test error", msg_no_frames)
    @test !occursin("error.jl", msg_no_frames)

    # maxLines=2 caps the number of appended frames. The resulting message
    # is strictly shorter than the default (which uses maxLines=20) when
    # the underlying trace has more than two frames.
    msg_limited = ExceptionCtrl.formatExceptionAndStackTrace(
        err, trace; maxLines = 2
    )
    @test occursin("intentional test error", msg_limited)
    @test length(msg_limited) < length(msg)

    # stopAt: when the pattern matches the first frame, the loop breaks
    # before appending any frame. The exception text is still there.
    msg_stopped = ExceptionCtrl.formatExceptionAndStackTrace(
        err, trace; stopAt = "error.jl"
    )
    @test occursin("intentional test error", msg_stopped)
    @test !occursin("error.jl", msg_stopped)

    # Empty stack trace: just the exception text, no frame lines.
    # `StackTrace` is `Vector{StackFrame}` from `Base.StackTraces`, which
    # is not re-exported by `runtests-prerequisite.jl`; construct an empty
    # one explicitly so the test does not depend on extra imports.
    emptyTrace = Base.StackTraces.StackFrame[]
    msg_empty = ExceptionCtrl.formatExceptionAndStackTrace(err, emptyTrace)
    @test msg_empty == "intentional test error"

end