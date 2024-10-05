
pymilvus = pyimport("pymilvus")

function insert(purpose::String, client::Py, base_dir::String)
	k = create(; purpose=purpose, base_dir=base_dir)
	upsert!(k, "clew"; client=client, base_dir=base_dir)
end

function parse_and_handle(sock::Sockets.TCPSocket, request::String, client::Py, model::Py)
	if startswith(request, "search")
		matches = match(r"data=\"(.*?)\" limit=(\d*) filters=\"(.*?)\"", request)
		data = string(matches.captures[1])
		limit = parse(Int, matches.captures[2] != "" ? matches.captures[2] : "10")
		filters = matches.captures[3]
		ret = search(data, client; model=model, limit=limit) |> prune
		second_elbow = find_elbow(ret.distances)
		for (i, x) in Iterators.reverse(enumerate(ret.values))
			option_format = "\033[4m" # underline
			key_format = "\033[38;5;245m" # medium gray
			purpose_format = ""
			format_reset = "\033[0m"
			if i < second_elbow
				# add bold formatting if result is particularly strong
				option_format = "$option_format\033[1m"
				key_format = "$key_format\033[1m"
				purpose_format = "$purpose_format\033[1m"
			end
			write(sock, " [$option_format$i$format_reset] ")
			write(sock, "$key_format$(x["key"])$format_reset: ")
			write(sock, "$purpose_format$(x["purpose"])$format_reset\n")
		end
	elseif startswith(request, "insert")
		matches = match(r"purpose=\"(.*?)\"", request)
		base_dir = match(r"base_dir=\"(.*?)\"", request)
		purpose = matches.captures[1]
		insert(client, purpose, base_dir)
	else
		write(sock, "Invalid command\n")
	end
end

function start_tcp_daemon(port::Int, client::Py, model::Py)
	server = listen(port)
	println("Daemon started, listening on port $port")
	while true
		sock = accept(server)
		@async begin
			try
				request = readline(sock)
				println("Handing request $request")
				parse_and_handle(sock, request, client, model)
			catch e
				println("Error handling client: $e")
			finally
				close(sock)
			end
		end
	end
end


