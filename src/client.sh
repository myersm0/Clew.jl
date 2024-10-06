#!/bin/bash

HOST="localhost"
PORT=2000
base_dir="$HOME/contents"

search() {
	local data=""
	local limit=""
	local filter=""
	local sort_by_date=false  # Default sorting is by similarity

	while [[ "$#" -gt 0 ]]; do
		case "$1" in
			--data=*)
				data="${1#*=}"
				;;
			--limit=*)
				limit="${1#*=}"
				;;
			--filter=*)
				filter="${1#*=}"
				;;
			--sort-by-date)
				sort_by_date=true
				;;
			*)
				echo "Unknown option: $1"
				return 1
				;;
		esac
		shift
	done

	request="search"

	if [[ -n "$data" ]]; then
		request="$request data=\"$data\""
	fi

	if [[ -n "$limit" ]]; then
		request="$request limit=$limit"
	fi

	if [[ -n "$filter" ]]; then
		request="$request filters=\"$filter\""
	fi

	if [[ "$sort_by_date" == true ]]; then
		request="$request sort=by_date"
	fi

	echo "$request"
	echo "$request" | nc $HOST $PORT
}

insert() {
	local purpose="$1"
	request="insert purpose=\"$purpose\""
	echo "$request" | nc $HOST $PORT
}

present_results() {
	# Search result keys passed as arguments
	local keys=($(echo -e "$@" | sed -r 's/... ([a-f0-9]{6}):.*/\1/'))  
	while true; do
		read -p "Enter choice (number or partial key): " choice

		if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
			echo "Exiting..."
			break
		fi

		if [[ "$choice" =~ ^[0-9]+$ ]]; then
			if (( choice > 0 && choice <= ${#keys[@]} )); then
				reverse_index=$(( ${#keys[@]} - choice ))  # Reverse choice to map to the correct index
				key="${keys[$reverse_index]}"
				cd "$base_dir/$key" || echo "Error: Directory $base_dir/$key does not exist."
				break
			else
				echo "Invalid number. Please try again."
			fi
		else
			# Handle partial key input
			matches=()
			for key in "${keys[@]}"; do
				if [[ "$key" =~ ^$choice ]]; then
					matches+=("$key")
				fi
			done

			# Ensure only one match for partial input
			if [[ ${#matches[@]} -eq 1 ]]; then
				cd "$base_dir/${matches[0]}" || echo "Error: Directory $base_dir/${matches[0]} does not exist."
				break
			elif [[ ${#matches[@]} -gt 1 ]]; then
				echo "Multiple matches found for '$choice':"
				for match in "${matches[@]}"; do
					echo "- $match"
				done
				echo "Please refine your input."
			else
				echo "No match found for '$choice'. Please try again."
			fi
		fi
	done
}

# Main script logic to decide which command to run
if [[ "$1" == "search" ]]; then
	# Shift past the "search" argument and pass the remaining ones to the search function
	shift
	results=$(search "$@")
	echo "$results"
	present_results "$results"

elif [[ "$1" == "insert" ]]; then
	# Run the insert function
	insert "$2"

else
	echo "Usage: $0 {search|insert} [arguments]"
	echo "Example: $0 search --data=\"some query\" --limit=5 --filter=\"metadata_filter\" --sort-by-date"
	echo "	$0 insert \"project purpose\""
fi

