
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

function search(query::String, client::Py; model::Py, limit::Int=20, filters::String="")
	embedding = make_embedding(query; model = model)
	ret = client.search(
		collection_name = collection_name,
		data = pylist([pycollist(embedding)]), 
		limit = limit,
		output_fields = pylist(["key", "purpose"]),
		filter = filters
	)
	return (
		distances = [pyconvert(Float64, x["distance"]) for x in ret[0]],
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

function perpendicular_distance(
		point::Vector{<:Number}, line_start::Vector{<:Number}, line_end::Vector{<:Number}
	)
	x1, y1 = line_start
	x2, y2 = line_end
	x0, y0 = point
	numerator = abs((y2 - y1)*x0 - (x2 - x1)*y0 + x2*y1 - y2*x1)
	denominator = sqrt((y2 - y1)^2 + (x2 - x1)^2)
	return numerator / denominator
end

function find_elbow(distances::Vector{<:Number})
	first_point = [1.0, distances[1]]
	last_point = [length(distances), distances[end]]
	distances = [
		perpendicular_distance([i, distances[i]], first_point, last_point) 
		for i in eachindex(distances)
	]
	elbow_index = argmax(distances)
	return elbow_index
end

function prune(results::NamedTuple)
	elbow = find_elbow(results.distances)
	elbow > 1 || error("Expected elbow to be at index >= 2")
	return (
		distances = results.distances[1:(elbow - 1)],
		values = results.values[1:(elbow - 1)]
	)
end




