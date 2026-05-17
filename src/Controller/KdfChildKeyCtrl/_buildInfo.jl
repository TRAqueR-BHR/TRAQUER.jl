function KdfChildKeyCtrl._buildInfo(infoPrefix::String, ref::Int16)::String
    # Build the info variable by concatenating the provided infoPrefix with the child key ref
    # If info-prefix ends with a letter or number, add an enclosing  of square brakets to
    # the ref (eg. '[45]')
    info = if endswith(infoPrefix, r"[A-Za-z0-9]$")
        "$infoPrefix[$ref]"
    else
        infoPrefix * string(ref)
    end

    return info
end
