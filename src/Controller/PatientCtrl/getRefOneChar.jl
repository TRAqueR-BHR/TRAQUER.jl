"""
    PatientCtrl.getRefOneChar(ref::AbstractString)

Extract the character of the reference that is used for partitioning (because it is not
always the first character)
TODO: Add something in the configuration so that we can use another character than ref[1]
"""
function PatientCtrl.getRefOneChar(ref::AbstractString)
    refOneChar = lowercase(ref[1])
    return refOneChar
end
