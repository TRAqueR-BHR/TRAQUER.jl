function _TestUtils.buildRandomAnalysisRef()
    # Generate a random analysis reference string
    # For example, you can use a combination of letters and numbers
    letters = 'A':'Z'
    numbers = '0':'9'
    ref_length = 8  # Length of the analysis reference
    ref = String(rand(letters, ref_length - 4)) * String(rand(numbers, 4))
    return ref
end
