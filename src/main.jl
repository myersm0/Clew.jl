
function julia_main()::Cint
	port = 2000
	db_path = "$base_dir/2f5963/clew.db"
	model = load_sbert()
	pymilvus = pyimport("pymilvus")
	client = pymilvus.MilvusClient(db_path)
	start_tcp_daemon(port, client, model)
	return 0
end



