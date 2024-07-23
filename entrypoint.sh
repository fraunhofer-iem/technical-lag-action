#!/bin/sh

set -e

inputPath=/github/workspace/$1
outputPath=/github/workspace/$2
analyzeSubDir=$3

DESTINATION_DIR="/tmp/packageFiles"
GRAPH_DIR="/tmp/graphs"

mkdir -p "$DESTINATION_DIR"
mkdir -p "$GRAPH_DIR"

# Function to copy package files if they exist
copy_package_files() {
    local src_dir=$1
    local dest_dir=$2
    mkdir -p "$dest_dir"
    for file in package.json package-lock.json yarn.lock; do
        if [ -f "$src_dir/$file" ]; then
            cp "$src_dir/$file" "$dest_dir"
            echo "Copied $file from $src_dir to $dest_dir"
        fi
    done
}

# Function to copy package files from inputPath and optionally from subdirectories
copy_files() {
    local base_dir=$1
    local dest_dir=$2

    # Copy package files from the base directory
    copy_package_files "$base_dir" "$dest_dir/root"

    # If analyzeSubDir is true, iterate over subdirectories and copy package files
    if [ "$analyzeSubDir" = "true" ]; then
        echo "Started analyzing subdirectories"
        find "$base_dir" -mindepth 1 -type d | while read -r dir; do
            # Create corresponding directory structure in DESTINATION_DIR
            relative_path="${dir#$base_dir/}"
            echo "Sub dir relative path $relative_path"
            copy_package_files "$dir" "$dest_dir/$relative_path"
        done
    fi
}

# Copy files from the inputPath to the DESTINATION_DIR
copy_files "$inputPath" "$DESTINATION_DIR"

sh /app/build/install/technical-lag-calculator/bin/technical-lag-calculator create-dependency-graph --projects-dir "$DESTINATION_DIR" --output-path "$GRAPH_DIR" 
sh /app/build/install/technical-lag-calculator/bin/technical-lag-calculator calculate-technical-lag --dependency-graph-dirs "$GRAPH_DIR" --output-path "$outputPath"
