#!/bin/bash

echo "Starting ollama server..."
ollama serve &
ollama run llama3


echo "Waiting for ollama server to be active..."
while [ "$(ollama list | grep 'NAME')" == "" ]; do
  sleep 1
done

echo "Loading gemma:2b..."
ollama pull gemma:2b
