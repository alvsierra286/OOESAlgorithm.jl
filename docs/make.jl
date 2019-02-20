using Documenter, OOESAlg

makedocs(modules=[OOESAlg],
         doctest = false,
         format = :html,
         sitename = "OOESAlg",
         authors = "Alvaro Sierra-Altamiranda",
         pages = Any[
        	"Home" => "index.md",
        	"Installation" => "installation.md",
        	"Getting Started" => "getting_started.md",
        	"Advanced Features" => "advanced.md",
        	"Solving Instances from Literature" => "solving_instances_from_literature.md"
    	])

deploydocs(
	repo = "github.com/alvsierra286/OOESAlg.git",
    target = "build",
    osname = "linux",
    julia  = "0.6",
    deps   = nothing,
    make   = nothing,
)
