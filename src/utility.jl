
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



