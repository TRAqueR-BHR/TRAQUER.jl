function FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(sidecarFilePath::String, cryptPwd::String)

    # Open the sidecar file and read its contents
    sidecarFileContents = read(sidecarFilePath, String)

    # Parse the contents of the sidecar file to extract the child key reference
    # Look for a line that matches one of the following:
    #   childKeyRef:*, childKeyRef=*, child_key_ref:*, child_key_ref=*, keyRef:*, keyRef=*,
    #   key_ref:*, key_ref=*
    childKeyRefPattern = r"(?i)(childKeyRef|child_key_ref|keyRef|key_ref)\s*[:=]\s*(\d+)"
    m = match(childKeyRefPattern, sidecarFileContents)
    if m === nothing
        error("Child key reference not found in sidecar file: $sidecarFilePath")
    end

    childKeyRef = parse(Int, m.captures[2])
    return childKeyRef

end
