module Clew

using PythonCall
using Chain
using JSON
using Dates
using Sockets
using StatsBase: sample
using LinearAlgebra

const base_dir = "$(ENV["HOME"])/contents/"
const pattern = r"^[0-9a-f]{6}$"
const collection_name = "clew"

include("types.jl")
include("sbert.jl")
include("ops.jl")
include("server.jl")
include("main.jl")

end



