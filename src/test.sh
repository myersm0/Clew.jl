#!/bin/bash

# Define the server and port
HOST="localhost"
PORT=2000

# Function to send a search request
search() {
	local data="$1"   # Required argument
	local limit="$2"  # Optional argument
	local metadata="$3"  # Optional argument for metadata filters
	
	# Construct the search command to send to the server
	request="search data=\"$data\""
	
	if [[ -n "$limit" ]]; then
		request="$request limit=$limit"
	fi

	if [[ -n "$metadata" ]]; then
		request="$request filters=\"$metadata\""
	fi
	
	# Send the request to the Julia server using netcat (nc)
	echo "$request" | nc $HOST $PORT
}

# Function to send an insert request
insert() {
	local purpose="$1"   # Required argument
	
	# Construct the insert command to send to the server
	request="insert purpose=\"$purpose\""
	
	# Send the request to the Julia server
	echo "$request" | nc $HOST $PORT
}

# Main script logic to decide which command to run
if [[ "$1" == "search" ]]; then
	# Run the search function
	search "$2" "$3" "$4"
elif [[ "$1" == "insert" ]]; then
	# Run the insert function
	insert "$2"
else
	echo "Usage: $0 {search|insert} [arguments]"
	echo "Example: $0 search \"some query\" 5 \"metadata_filter\""
	echo "    $0 insert \"project purpose\""
fi

