function PatientCtrl.getRefOneChar(ref::AbstractString)
    refOneChar = lowercase(ref[1])
    return refOneChar
end
