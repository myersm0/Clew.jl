
pymilvus = pyimport("pymilvus")

function insert(purpose::String, client::Py, base_dir::String)
	k = create(; purpose=purpose, base_dir=base_dir)
	upsert!(k, "clew"; client=client, base_dir=base_dir)
end

function start_tcp_daemon(port::Int, client::Py, model::Py)
	server = listen(ip"127.0.0.1", port)
	println("Daemon started, listening on port $port")
	while true
		sock = accept(server)
		@async begin
			try
				request = readline(sock)
				println("Handling request $request")
				parse_and_handle(sock, request, client, model)
			catch e
				println("Error handling client: $e")
			finally
				close(sock)
			end
		end
	end
end

# Parse the client's request into two parts, a command and a dict of key-value pairs
function parse_request(request::String)
	key_value_regex = r"--(\w+)=?\"?([^\"]*)\"?"
	parts = split(request, r"\s+", limit=2)
	command = Symbol(parts[1])
	kwargs = Dict{Symbol, String}()
	if length(parts) > 1
		for match in eachmatch(key_value_regex, parts[2])
			key = Symbol(match.captures[1])
			value = strip(match.captures[2])
			kwargs[key] = value
		end
	end
	return command, kwargs
end

function parse_and_handle(sock::Sockets.TCPSocket, request::String, client::Py, model::Py)
	command, kwargs = parse_request(request)
	@match command begin
		:search => handle_search(sock, client, model; kwargs...)
		:insert => handle_insert(sock, client, model; kwargs...)
		_ => write(sock, "Invalid command\n")
	end
end

function handle_search(sock::Sockets.TCPSocket, client::Py, model::Py; kwargs...)
	data = get(kwargs, :data, "")
	limit = parse(Int, get(kwargs, :limit, "10"))
	filter = get(kwargs, :filter, "")

	ret = search(
		data, client; model=model, limit=limit, filter=filter
	) |> prune
	second_elbow = find_elbow(ret.distances)

	for (i, x) in Iterators.reverse(enumerate(ret.values))
		option_format = "\033[4m"  # underline
		key_format = ""
		purpose_format = ""
		format_reset = "\033[0m"
		if i < second_elbow
			option_format = "$option_format\033[1m"  # bold if particularly strong result
			purpose_format = "$purpose_format\033[1m"
		end
		write(sock, "[$option_format$i$format_reset] ")
		write(sock, "$key_format$(x["key"])$format_reset: ")
		write(sock, "$purpose_format$(x["purpose"])$format_reset\n")
	end
end

function handle_insert(sock::Sockets.TCPSocket, client::Py, model::Py; kwargs...)
	k = create(; kwargs...)
	upsert!(k, client; base_dir=kwargs[:base_dir], model = model)
end


