module Clew

using PythonCall
using LinearAlgebra
using Chain
using ArgParse
using JSON
using Dates
using NamedArrays
using Sockets
using StatsBase: sample

base_dir = "$(ENV["HOME"])/contents/"
db_path = "$base_dir/2f5963/clew.db"
pattern = r"^[0-9a-f]{6}$"
ks = filter(x -> occursin(pattern, x), readdir(base_dir))

include("types.jl")
export Content

include("sbert.jl")
export load_sbert
model = load_sbert()

include("ops.jl")

pymilvus = pyimport("pymilvus")
client = pymilvus.MilvusClient(db_path)
include("server.jl")

start_tcp_daemon(2000)

end





