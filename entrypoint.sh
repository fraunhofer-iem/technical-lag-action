#!/bin/sh

set -e
# we probably need to map this with /github/workspace
inputPath=/github/workspace/$1
outputPath=/github/workspace/$2
# we move the package manager files to a separate directory to make it easier for the ORT

# Base directory where package files will be copied
DESTINATION_DIR="tmp/packageFiles"

# Create the base destination directory if it doesn't exist
mkdir -p "$DESTINATION_DIR"

# Function to copy package files if they exist
copy_package_files() {
    local src_dir=$1
    local dest_dir=$2

    # Copy the package files if they exist
    if [ -f "$src_dir/package.json" ]; then
        cp "$src_dir/package.json" "$dest_dir"
    fi
    if [ -f "$src_dir/package-lock.json" ]; then
        cp "$src_dir/package-lock.json" "$dest_dir"
    fi
    if [ -f "$src_dir/yarn.lock" ]; then
        cp "$src_dir/yarn.lock" "$dest_dir"
    fi
}

copy_package_files "$inputPath" "$DESTINATION_DIR"

./build/install/technical-lag-calculator/bin/technical-lag-calculator create-dependency-graph --projects-dir "$DESTINATION_DIR" --output-path /graphs 
./build/install/technical-lag-calculator/bin/technical-lag-calculator calculate-technical-lag --dependency-graph-dirs /graphs --output-path $outputPath 