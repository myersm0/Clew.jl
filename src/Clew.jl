module Clew

using PythonCall
using Chain
using JSON
using Dates
using Sockets
using StatsBase: sample
using LinearAlgebra
using ArgParse

const pattern = r"^[0-9a-f]{6}$"
const collection_name = "clew"

include("types.jl")
include("sbert.jl")
include("ops.jl")
include("server.jl")
include("main.jl")

end



