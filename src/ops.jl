
# todo: allow passing in a vector of Content instead of many calls to this fn
function upsert!(collection_name::String, c::Content; client::Py)
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

function upsert!(collection_name::String, k::String; client::Py, base_dir::String)
	c = Content("$base_dir/$k/.clew"; model = model)
	upsert!("clew", c; client = client)
end

function upsert!(collection_name::String, ks::Vector{String}; client::Py, base_dir::String)
	for k in ks
		upsert!("clew", k; client = client, base_dir = base_dir)
	end
end

function search(collection_name::String, query::String; client::Py, model::Py, limit::Int)
	embedding = make_embedding("notes for system admin"; model = model)
	ret = client.search(
		collection_name = "clew", 
		data = pylist([pycollist(embedding)]), 
		limit = limit,
		output_fields = pylist(["key", "purpose"])
	)[0]
	return [pyconvert(Dict, x["entity"]) for x in ret]
end

function randhex(n::Int = 6)
	@chain "0123456789abcdef" begin
		split(_, "")
		sample(_, n; replace = true)
		join
	end
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

function get_keys(collection_name::String = "clew")
	ids = client.query(
		collection_name = collection_name, filter = "key != ''", output_fields = pylist(["key"])
	)
	isempty(ids) && return nothing
	return [pyconvert(String, x["key"]) for x in ids]
end

function delete!(collection_name::String, ids::Vector{String})
	client.delete(collection_name = "clew", filter = "key in $(ids)")
end








