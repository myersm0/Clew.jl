
function randhex(n::Int = 6)
	@chain "0123456789abcdef" begin
		split(_, "")
		sample(_, n; replace = true)
		join
	end
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

function find_elbow(similarities::Vector{<:Number})
	first_point = [1.0, similarities[1]]
	last_point = [length(similarities), similarities[end]]
	similarities = [
		perpendicular_distance([i, similarities[i]], first_point, last_point) 
		for i in eachindex(similarities)
	]
	elbow_index = argmax(similarities)
	return elbow_index
end

function prune(results::NamedTuple)
	elbow = find_elbow(results.similarities)
	elbow > 1 || error("Expected elbow to be at index >= 2")
	return (
		similarities = results.similarities[1:(elbow - 1)],
		values = results.values[1:(elbow - 1)]
	)
end



