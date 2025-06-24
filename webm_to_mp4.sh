#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 input_file.webm"
  exit 1
fi

input="$1"
output="${input%.webm}.mp4"

ffmpeg -i "$input" -vsync passthrough -c:v libx264 "$output"