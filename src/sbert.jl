
function cos_sim(a::AbstractVector, b::AbstractVector)
	return dot(a, b) / (norm(a) * norm(b))
end

function load_sbert(model_name::String = "all-mpnet-base-v2")
	return pyimport("sentence_transformers").SentenceTransformer(model_name)
end

function make_embedding(input::String; model::Py)::Vector
	return @chain model.encode(input) pyconvert(Array, _)
end

function make_embeddings(inputs::Vector{String}; model::Py)::Matrix
	return @chain model.encode(inputs) pyconvert(Array, _) transpose
end

function rank_by_relevance(query::String, collection::Vector{String}; model::Py)
	query_embedding = make_embedding(query; model = model)
	targ_embeddings = make_embeddings(collection; model = model)
	scores = map(x -> cos_sim(query_embedding, x), eachcol(targ_embeddings))
	rank_order = scores |> sortperm |> reverse
	return (scores = scores[rank_order], elements = collection[rank_order])
end

function rank_by_relevance(query::String, collection::NamedVector{Content}; model::Py)
	query_embedding = make_embedding(query; model = model)
	targ_embeddings = hcat([c.embedding for c in collection]...)
	scores = map(x -> cos_sim(query_embedding, x), eachcol(targ_embeddings))
	rank_order = scores |> sortperm |> reverse
	scores = scores[rank_order]
	notes = [collection[k].meta["purpose"] for k in keys(collection)[rank_order]]
	ks = [collection[k].meta["key"] for k in keys(collection)[rank_order]]
	return (
		scores = scores[rank_order], 
		keys = keys(collection)[rank_order]
	)
end

function rank_by_relevance(query::String, collection::Vector{Content}; model::Py)
	query_embedding = make_embedding(query; model = model)
	targ_embeddings = hcat([c.embedding for c in collection]...)
	scores = map(x -> cos_sim(query_embedding, x), eachcol(targ_embeddings))
	rank_order = scores |> sortperm |> reverse
	return (
		scores = scores[rank_order], 
		elements = [collection[k].meta["purpose"] for k in keys(collection)[rank_order]]
	)
end

