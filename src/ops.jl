
# todo: allow passing in a vector of Content instead of many calls to this fn
function upsert!(c::Content, client::Py)
	client.upsert(
		collection_name = collection_name,
		data = pylist(
			pydict.(
				[
					Dict(
						"key" => c.meta["key"],
						"vector" => c.embedding,
						"purpose" => c.meta["purpose"],
						"created" => Date(c.meta["created"], dateformat"y-m-d").instant.periods.value,
						"author" => c.meta["author"]
					)
				]
			)
		)
	)
end

function upsert!(k::String, client::Py; base_dir::String = base_dir)
	c = Content("$base_dir/$k/.clew"; model = model)
	upsert!(c, client = client)
end

function upsert!(ks::Vector{String}, client::Py; base_dir::String = base_dir)
	for k in ks
		upsert!(k, client; base_dir = base_dir)
	end
end

function search(query::String, client::Py; model::Py, limit::Int=5, filters::String="")
	embedding = make_embedding(query; model = model)
	ret = client.search(
		collection_name = collection_name,
		data = pylist([pycollist(embedding)]), 
		limit = limit,
		output_fields = pylist(["key", "purpose"]),
		filter = filters
	)
	return (
		distances = [pyconvert(Float64, x["distances"]) for x in ret[0]],
		values = [pyconvert(Dict, x["entity"]) for x in ret[0]]
	)
end

function randhex(n::Int = 6)
	@chain "0123456789abcdef" begin
		split(_, "")
		sample(_, n; replace = true)
		join
	end
end

function create(; purpose::String, base_dir::String = base_dir, date::Union{String, Nothing} = nothing)
	key = randhex(6)
	dest = "$base_dir/$key/"
	!isdir(dest) || error("Target directory $key already exists")
	run(`mkdir -p $dest`)

	meta = Dict(
		:key => key,
		:purpose => purpose,
		:author => ENV["USER"],
		:created => isnothing(date) ? string(Dates.today()) : date
	)

	outname = "$dest/.clew"
	open(outname, "w") do fid
		JSON.print(fid, meta, 4) # pretty print json with tabwidth 4
	end

	println("Successfully created a new content directory at $dest")
	return key
end

function get_keys(client::Py, collection_name::String = collection_name)
	ids = client.query(
		collection_name = collection_name, filter = "key != ''", output_fields = pylist(["key"])
	)
	isempty(ids) && return nothing
	return [pyconvert(String, x["key"]) for x in ids]
end

function delete!(ids::Vector{String}, client::Py)
	client.delete(collection_name = collection_name, filter = "key in $(ids)")
end








