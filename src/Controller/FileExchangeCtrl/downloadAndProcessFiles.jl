function FileExchangeCtrl.downloadAndProcesFiles(
    fileURLs::Vector{String},
    cryptPwd::String,
    dbconn::LibPQ.Connection
)

    # Download files at given URL (it can be s3:// or file://)

    # Process them in order

end
