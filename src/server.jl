
pymilvus = pyimport("pymilvus")
client = pymilvus.MilvusClient(db_path)

function insert(purpose::String, client::Py)
	k = create(; purpose=purpose, base_dir=base_dir)
	upsert!(k, "clew"; client=client, base_dir=base_dir)
end

function parse_and_handle(request::String, client::Py, sock::Sockets.TCPSocket)
	if startswith(request, "search")
		matches = match(r"data=\"(.*?)\" limit=(\d*) filters=\"(.*?)\"", request)
		data = string(matches.captures[1])
		limit = parse(Int, matches.captures[2] != "" ? matches.captures[2] : "10")
		filters = matches.captures[3]
		ret = search(data, client; model=model, limit=limit) |> prune
		for (i, x) in Iterators.reverse(enumerate(ret.values))
			write(sock, "[$i] $(x["key"]): $(x["purpose"])\n")
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
				println("Handing request $request")
				parse_and_handle(request, client, sock)
			catch e
				println("Error handling client: $e")
			finally
				close(sock)
			end
		end
	end
end


