# Clew

## Introduction
This is a project supporting a file & directory management strategy which I find extremely helpful but which is probably not going to appeal to anyone else. Still, I'm making this public in case it could be helpful to anyone. As a recently disabled typist, I've been focusing on developing and sharing tools like this to increase productivity at the computer.

The way it works is that I store all my directories (of notes, media, datasets, code projects, repos, anything) at a single level of hierarchy, and I give no thought to their naming or organization but rather leave that to metadata and docs within each directory to fuel semantic search. The folders are all given random, meaningless names. This enables me to quickly iterate through ideas, and yet always be able to quickly find whatever I need. It has innumerable other benefits.

It depends on two Python packages, the `pymilvus` ("Milvus Lite") vector database and `sentence-transformers` for a local SentenceBERT AI model. These things drive the semantic search and topic modeling capabilities.

The name "clew" is derived from the Greek myth of the labyrinth, a reference to the thread that enabled the hero to retrace his steps and find the way. Also it's a short word with few sound-alikes in English, which is important for me as I control my computer primarily by voice (with [Talon](https://talonvoice.com/)).

This is a work in progress.

## Installation
Installing the Python dependencies and having them work with Julia's `PythonCall` can be tricky. Here's how I do it. First install Miniconda, then:
```
conda create --name my_env
conda activate my_env
conda install pip
pip install -U pymilvus sentence-transformers
export JULIA_CONDAPKG_BACKEND="System"
export JULIA_PYTHONCALL_EXE="$HOME/resources/miniconda3/envs/m/bin/python"
```

Those latter two lines seem to be necessary to get `PythonCall` to recognize packages from your currently active conda environment. Then, cd into this repo, start Julia with `julia --project` and:
```
using PackageCompiler
create_app(".", "app")
```

That should create an executable binary in the repo at `app/bin/Clew`, which you can run with `app/bin/Clew --db_path="/path/to/my/milvus.db" --port=2000`. You'll probably want to have it running in the background. Leave that running as a server (listening for requests on `localhost:2000`), and you can then interact with it from other terminals via the provided `client.sh` script. You may want to edit `client.sh` for your own use cases and move it to somewhere in your `$PATH`, add some aliases, etc.

It will need to have an already-existing Milvus database file, however, that has a collection called "clew" with a certain schema which is outlined in `examples/create.jl`. I'll eventually add that as functionality in this package, but for now you could set it up yourself by example.

[![Build Status](https://github.com/myersm0/Clew.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/Clew.jl/actions/workflows/CI.yml?query=branch%3Amain)
