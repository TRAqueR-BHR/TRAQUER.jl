import Pkg;
#Pkg.add("Documenter")
using Documenter, TRAQUER, TRAQUER.Controller

makedocs(
        sitename = "TRAQUER documentation",
        # modules = [PostgresORM],
        pages = ["Index" => "index.md",
                 "Getting started" => "getting-started.md",
                 "Modules" => [
                        "modules/TRAQUER.md",
                        "modules/Controller.InfectiousStatusCtrl.md"
                        ]
                 ],
)
deploydocs(; repo = "github.com/TRAqueR-BHR/TRAQUER.jl.git",
             devbranch = "main")
