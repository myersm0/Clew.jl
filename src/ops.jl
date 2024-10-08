
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

function upsert!(k::String, client::Py; base_dir::String = base_dir, model::Py)
	c = Content("$base_dir/$k/.clew"; model = model)
	upsert!(c, client)
end

function upsert!(ks::Vector{String}, client::Py; base_dir::String = base_dir, model::Py)
	for k in ks
		upsert!(k, client; base_dir = base_dir, model = model)
	end
end

function search(data::String, client::Py; model::Py, limit::Int=20, filter::String="")
	embedding = make_embedding(data; model = model)
	ret = client.search(
		collection_name = collection_name,
		data = pylist([pycollist(embedding)]), 
		limit = limit,
		output_fields = pylist(["key", "purpose"]),
		filter = filter
	)
	return (
		similarities = [pyconvert(Float64, x["distance"]) for x in ret[0]],
		values = [pyconvert(Dict, x["entity"]) for x in ret[0]]
	)
end

function create(; purpose::String, base_dir::String, date::Union{String, Nothing} = nothing)
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

