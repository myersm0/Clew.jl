

function search(client, data::String; model::Py, limit::Int=5, filters::String="")
	println("The data is $data")
	embedding = make_embedding(data; model = model)
	search_vector = pylist([pycollist(embedding)])
	ret = client.search(
		collection_name="clew",
		data=search_vector,
		limit=limit,
		output_fields=pylist(["key", "purpose"])
	)
	println("Got it")
	return([pyconvert(Dict, x["entity"]) for x in ret[0]])
end

function insert(client, purpose::String)
	k = create(; purpose = purpose, base_dir = base_dir)
	upsert!("clew", k; client = client, base_dir = base_dir)
end

function parse_and_handle(sock::Sockets.TCPSocket, request::String, client)
	if startswith(request, "search")
		matches = match(r"data=\"(.*?)\" limit=(\d*) filters=\"(.*?)\"", request)
		data = string(matches.captures[1])
		limit = parse(Int, matches.captures[2] != "" ? matches.captures[2] : "10")
		filters = matches.captures[3]
		ret = search(client, data; model = model, limit=limit)
		for x in ret
			write(sock, "▪\t$(x["key"])\t$(x["purpose"])\n")
		end
	elseif startswith(request, "insert")
		matches = match(r"purpose=\"(.*?)\"", request)
		purpose = matches.captures[1]
		insert(client, purpose)
	else
		write(sock, "Invalid command\n")
	end
end

function start_tcp_daemon(port::Int)
	server = listen(port)
	println("Daemon started, listening on port $port")
	while true
		sock = accept(server)
		@async begin
			try
				request = readline(sock)
				println("The request is $request")
				parse_and_handle(sock, request, client)
			catch e
				println("Error handling client: $e")
			finally
				close(sock)
			end
		end
	end
end


