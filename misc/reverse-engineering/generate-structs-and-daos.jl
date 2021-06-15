using PostgresqlDAO
using LibPQ


dbconn = begin
   database = "traquer"
   user = "traquer"
   host = "127.0.0.1"
   port = "5432"
   password = "Root95"

   conn = LibPQ.Connection("host=$(host)
                            port=$(port)
                            dbname=$(database)
                            user=$(user)
                            password=$(password)
                            "; throw_error=true)
end
outdir = "/home/root95/Documents/Traquer/TRAQUER.jl/misc/reverse-engineering/out"
PostgresqlDAO.Tool.generate_julia_code(dbconn, outdir
                                       ;module_name_for_all_schemas = "Model")
close(dbconn)
