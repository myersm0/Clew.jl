
schema = pymilvus.MilvusClient.create_schema(
	auto_id = false, enable_dynamic_field = false
)
schema.add_field(
	field_name = "key", 
	datatype = pymilvus.DataType.VARCHAR, 
	is_primary = true, 
	max_length = 6
)
schema.add_field(
	field_name = "vector", 
	datatype = pymilvus.DataType.FLOAT_VECTOR, 
	dim = 768
)
schema.add_field(
	field_name = "purpose", 
	datatype = pymilvus.DataType.VARCHAR,
	max_length = 256
)
schema.add_field(
	field_name = "author", 
	datatype = pymilvus.DataType.VARCHAR,
	max_length = 32
)
schema.add_field(
	field_name = "created", 
	datatype = pymilvus.DataType.INT64
)

client.create_collection(collection_name = collection_name, schema = schema)

index_params = pymilvus.MilvusClient.prepare_index_params()
index_params.add_index(
	field_name = "vector",
	metric_type = "COSINE",
	index_type = "FLAT",
	index_name = "vector_index",
	params = pydict()
)

client.create_index(collection_name = collection_name, index_params = index_params)

model = load_sbert()
ks = filter(x -> occursin(pattern, x), readdir(base_dir))
upsert!(ks, client; base_dir = base_dir)






