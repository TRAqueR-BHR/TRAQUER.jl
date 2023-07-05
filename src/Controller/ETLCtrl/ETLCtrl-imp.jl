include("serializeRowsInError.jl")

function ETLCtrl.importStays(
    df::DataFrame,
    encryptionStr::AbstractString
    ;stopAfterXLines::Number = Inf64)

    # Custom.importStays(df, encryptionStr ;stopAfterXLines = stopAfterXLines)

end

function ETLCtrl.importAnalyses(
    df::DataFrame,
    encryptionStr::AbstractString
    ;stopAfterXLines::Number = Inf64)

    # Custom.importAnalyses(df, encryptionStr ;stopAfterXLines = stopAfterXLines)

end
