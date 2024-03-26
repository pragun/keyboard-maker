#!/bin/bash

# Check if the correct number of arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path to YAML file> <path to clone git repo>"
    exit 1
fi

YAML_FILE="$1"
CLONE_PATH="$2"

# Convert CLONE_PATH to an absolute path if it is not already
# This ensures the path passed to lib_manager.py is absolute
CLONE_PATH=$(realpath "$CLONE_PATH")

# Parse YAML File
GIT_URL=$(yq e '.git-url' "$YAML_FILE")

# Exit if GIT_URL is empty
if [ -z "$GIT_URL" ]; then
    echo "Git URL not found in the YAML file."
    exit 1
fi

# Clone the Git repository
git clone "$GIT_URL" "$CLONE_PATH" || { echo "Failed to clone repo"; exit 1; }

# Function to add footprint libraries
add_fp_libs() {
    yq e '.fp-libs[]' "$YAML_FILE" -o=json | jq -r '. | "\(.name) \(.subpath)"' | while read -r name subpath; do
        python lib_manager.py add-fp --name "$name" --path "${CLONE_PATH}/${subpath}"
    done
}

# Function to add symbol libraries
add_sym_libs() {
    yq e '.sym-libs[]' "$YAML_FILE" -o=json | jq -r '. | "\(.name) \(.subpath)"' | while read -r name subpath; do
        python lib_manager.py add-sym --name "$name" --path "${CLONE_PATH}/${subpath}"
    done
}

# Add the libraries
add_fp_libs
add_sym_libs

