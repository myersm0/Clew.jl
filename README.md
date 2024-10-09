# Clew

## Introduction
This is a project supporting a file & directory management strategy which I find extremely helpful but which is probably not going to appeal to anyone else. Still, I'm making this public in case it could be helpful to anyone. As a recently disabled typist, I've been focusing on developing and sharing tools like this to increase productivity at the computer.

The way it works is that I store all my directories (of notes, media, datasets, code projects, repos, anything) at a single level of hierarchy, and I give no thought to their naming or organization but rather leave that to metadata and docs within each directory to fuel semantic search. The folders are all given random, meaningless names. This enables me to quickly iterate through ideas, and yet always be able to quickly find whatever I need. It has innumerable other benefits.

It depends on two Python packages, the `pymilvus` ("Milvus Lite") vector database and `sentence-transformers` for a local SentenceBERT AI model. These things drive the semantic search and topic modeling capabilities.

This is a work in progress.

## Installation
Installing the Python dependencies and having them work with Julia's `PythonCall` can be tricky. Here's how I do it. First install Miniconda, then in bash:
```bash
conda create --name my_env
conda activate my_env
conda install pip
pip install -U pymilvus sentence-transformers
git clone https://github.com/myersm0/Clew.jl
cd Clew.jl
export JULIA_CONDAPKG_BACKEND="System"
export JULIA_PYTHONCALL_EXE="/path/to/miniconda/envs/my_env/bin/python"
```

Those latter two lines seem to be necessary to get `PythonCall` to recognize packages from your currently active conda environment. Then start Julia with `julia --project` and:
```julia
using PackageCompiler
create_app(".", "app")
```

That should create an executable binary in the repo at `app/bin/Clew`, which you can run from the terminal with `app/bin/Clew --db_path="/path/to/my/milvus.db" --port=2000`. Leave that running in the background as a server (it will be listening for requests on `localhost:2000` by default), and you can then interact with it from other terminals via the provided `client.sh` script. You may want to edit `client.sh` for your own use cases and move it to somewhere in your `$PATH`, add some aliases, etc.

It will need to have an already-existing Milvus database file, however, that has a collection called "clew" with a certain schema which is outlined in `examples/create.jl`. I'll eventually add that as functionality in this package, but for now you could set it up yourself by example.

## Usage
Assuming you already have a Milvus database following the specified schema (see the last line in the section above) with some entries that have been inserted, you can search those entries from bash, over the Julia server that this package provides, in a way that's intentionally very similar to doing so within Milvus itself (see, for example, [this](https://milvus.io/api-reference/pymilvus/v2.3.x/MilvusClient/Vector/search.md)). 

First you may want to define an alias like this:
```bash
alias clew="source /path/to/my/client.sh"
```

Then you can do this:
```bash
$ clew search --data="linear algebra"
```

`data` is your search query. For me, this returns the following results:
```bash
[3] 2234f5: MIT opencourseware 217 (graph theory) course materials
[2] 55b3e2: MIT linear algebra lecture notes and julia code from different semesters
[1] 334334: code to accompany Vectors, Matrices, and Least Squares book
Go to:  
```

This output is two things in one:
- a list of matching directories (for each, a 6-digit hex ID and a statement describing the contents) in ascending order by relevance to the query
- a menu from which you can select one of these directories and `cd` into it by typing the associated ranking number (1, 2, or 3 in this case), or type `q` to quit.

To select the list of relevant results from the total set of directories available, a cosine similarity search is done and from those similarity scores an elbow method is used to truncate the list to a manageable number of results. 

You can also add filters to limit results based on metadata fields:
```bash
$ clew search --data="linear algebra" --filter="author == '$whoami' and created >= '2024-01-01'"
```

You could omit the semantic search query and just use filters like this, in which case results will be sorted by creation date:
```bash
$ clew search --filter="author == '$whoami' and created >= '2024-01-01'"
```

[![Build Status](https://github.com/myersm0/Clew.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/Clew.jl/actions/workflows/CI.yml?query=branch%3Amain)
