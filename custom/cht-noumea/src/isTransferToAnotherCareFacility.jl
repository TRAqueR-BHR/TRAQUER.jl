function Custom.isTransferToAnotherCareFacility(str::Missing)
    return false
end

function Custom.isTransferToAnotherCareFacility(str::String)
    if startswith(str,r"transfert"i) || startswith(str,r"placement maison de retraite"i)
        return true
    end

    return false
end
