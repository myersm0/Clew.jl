# Clew

## Introduction
This is a project supporting a file & directory management strategy which I find extremely helpful but which is probably not going to appeal to anyone else. Still, I'm making this public in case it could be helpful to anyone. As a recently disabled typist, I've been focusing on developing and sharing tools like this to increase productivity at the computer.

The way it works is that I store all my directories (of notes, media, datasets, code projects, repos, anything) at a single level of hierarchy, and I give no thought to their naming or organization but rather leave that to metadata and docs within each directory to fuel semantic search. The folders are all given random, meaningless names. This enables me to quickly iterate through ideas, and yet always be able to quickly find whatever I need. It has innumerable other benefits.

It depends on two Python packages, the `pymilvus` ("Milvus Lite") vector database and `sentence-transformers` for a local SentenceBERT AI model. These things drive the semantic search and topic modeling capabilities.

The name "clew" is derived from the Greek myth of the labyrinth, a reference to the thread that enabled the hero to retrace his steps and find the way. Also it's a short word with few sound-alikes in English, which is important for me as I control my computer primarily by voice (with [Talon]("https://talonvoice.com/")).

This is a work in progress.

[![Build Status](https://github.com/myersm0/Clew.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/Clew.jl/actions/workflows/CI.yml?query=branch%3Amain)
