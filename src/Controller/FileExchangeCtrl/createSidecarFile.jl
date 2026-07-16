"""
    FileExchangeCtrl.createSidecarFile(_path::String, keyRef::Int)

Create a sidecar file at `_path` containing a single line in the format
`key_ref=<keyRef>` (followed by a trailing newline). The format is
compatible with `FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile`,
which parses the key reference back out during the file-exchange
processing pipeline.

If a file already exists at `_path`, it is overwritten.
"""
function FileExchangeCtrl.createSidecarFile(_path::String, keyRef::Int16)

    write(_path, "key_ref=$(keyRef)\n")

    return nothing

end
