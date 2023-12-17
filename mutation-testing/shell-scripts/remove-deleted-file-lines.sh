#!/bin/bash

input_file="git.diff"
temp_file="temp_diff_file.diff"

# Reverse the file, remove 4 lines after '+++ /dev/null', then reverse it back (editors can't go backwards - to remove lines above)
tac "$input_file" > "$temp_file" && mv "$temp_file" "$input_file"
sed '/+++ \/dev\/null/{n;N;N;N;d;}' "$input_file" > "$temp_file" && mv "$temp_file" "$input_file"
tac "$input_file" > "$temp_file" && mv "$temp_file" "$input_file"

# Remove the lines between '+++ /dev/null' (included) and 'diff --git a/'
awk '
  BEGIN { in_block=0 }
  /\+\+\+ \/dev\/null/ { in_block=1; next }
  in_block && /diff --git a\// { in_block=0; print; next }
  !in_block
' "$input_file" > "$temp_file" && mv "$temp_file" "$input_file"
