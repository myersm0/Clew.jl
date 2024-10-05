
function arg_parse_wrapper(args)
	s = ArgParseSettings()
	@add_arg_table! s begin
		"--port"
			help = "The port on which the server will listen for requests"
			arg_type = Int
			default = 2000
		"--db_path"
			help = "The full path of an existing Milvus .db file to use (see create.jl)"
			arg_type = String
			required = true
	end
	return parse_args(s; as_symbols = true)
end

function julia_main()::Cint
	args = arg_parse_wrapper(ARGS)
	model = load_sbert()
	pymilvus = pyimport("pymilvus")
	client = pymilvus.MilvusClient(args[:db_path])
	start_tcp_daemon(args[:port], client, model)
	return 0
end



