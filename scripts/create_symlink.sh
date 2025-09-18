#!/bin/bash
set -e
mkdir -p "$2"
for object in "$1"/*; do
  # Check if object is a file, if it is a file, create a symlink
  if [ -f "$object" ]; then
    ln -sf "$(realpath "$object")" "$2/"
  # Check if object is a folder, if it is a folder loop over all files in that folder
  elif [ -d "$object" ]; then
    subdir_name="$(basename "$object")"
    mkdir -p "$2/$subdir_name"
    for f in "$object"/*; do
      if [ -f "$f" ]; then
        ln -sf "$(realpath "$f")" "$2/$subdir_name/"
      fi
    done
  fi
done

