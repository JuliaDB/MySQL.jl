module API

using Dates, DecFP, MariaDB_Connector_C_jll

# Load libmariadb from our deps.jl
# const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
# if !isfile(depsjl_path)
#     error("MySQL not installed properly, run Pkg.build(\"MySQL\"), restart Julia and try again")
# end
# include(depsjl_path)

# const definitions from mysql client library
include("consts.jl")

# lowest-level ccall definitions
include("ccalls.jl")

# api data structure definitions and wrappers
include("apitypes.jl")

# C API functions
include("capi.jl")

# Prepared statement API functions
include("papi.jl")

end # module