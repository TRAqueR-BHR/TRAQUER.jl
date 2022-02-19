using Pkg
Pkg.activate(".")

# Ajout du chemin vers PostgresORM dans le path de julia
push!(LOAD_PATH, ENV["PostgresORM_PATH"])

using PostgresORM
using LibPQ


dbconn = begin
   database = "traquer"
   user = "traquer"
   host = "127.0.0.1"
   port = "5432"
   password = "toto90"

   conn = LibPQ.Connection("host=$(host)
                            port=$(port)
                            dbname=$(database)
                            user=$(user)
                            password=$(password)
                            "; throw_error=true)
end
out_dir = (@__DIR__) * "/out"
PostgresORM.Tool.generate_julia_code(dbconn, out_dir
                                    ;module_name_for_all_schemas = "Model")
close(dbconn)
