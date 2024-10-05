module Clew

using PythonCall
using Chain
using JSON
using Dates
using Sockets
using StatsBase: sample

const base_dir = "$(ENV["HOME"])/contents/"
const db_path = "$base_dir/2f5963/clew.db"
const pattern = r"^[0-9a-f]{6}$"
const collection_name = "clew"
const port = 2000

include("types.jl")
include("sbert.jl")
include("ops.jl")
include("server.jl")

model = load_sbert()
start_tcp_daemon(port)

end



