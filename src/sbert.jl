
function load_sbert(model_name::String = "all-mpnet-base-v2")
	return pyimport("sentence_transformers").SentenceTransformer(model_name)
end

function make_embedding(input::String; model::Py)::Vector
	return @chain model.encode(input) pyconvert(Array, _)
end

function make_embeddings(inputs::Vector{String}; model::Py)::Matrix
	return @chain model.encode(inputs) pyconvert(Array, _) transpose
end

