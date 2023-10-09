# WebSocket server
@everywhere function websocket_def(x)
    @info "Open websocket"
    while !eof(x[:socket])
        if !isopen(x[:socket])
            return
        end
        obj = String(read(x[:socket])) |> JSON.parse
        # @info "Received data on websocket: " obj


        if haskey(obj,"action") && obj["action"] == "checkIfAnyPendingTask"
            somePendingTasks = createDBConnAndExecute() do dbconn
                TaskWaitingForUserExecutionCtrl.checkIfAnyPendingTask(dbconn)
            end
            if somePendingTasks
                write(
                    x[:socket],
                    String(JSON.json(
                        Dict("action" => "executePendingTasks")
                    ))
                )
            end
        end


    end
end

@app web_socket = (
    Mux.wdefaults,
    route("/api/websocket", websocket_def),
    Mux.wclose,
    Mux.notfound()
)
