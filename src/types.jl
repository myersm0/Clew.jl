
struct Content
	embedding::Vector{Float32}
	meta::Dict{String, Any}
end

function Content(filename::String; model::Py)
	meta = open(filename, "r") do fid
		JSON.parse(fid)
	end
	embedding = make_embedding(meta["purpose"]; model = model)
	return Content(embedding, meta)
end

