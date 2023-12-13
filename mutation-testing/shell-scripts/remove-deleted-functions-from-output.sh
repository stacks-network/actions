#!/bin/bash

# Flow:
#
# Parse through all the lines of the file
# When we find a line that starts with '--- a/', we save what is after the 'a/' to a 'file_path' variable
# When we find a line that contains the word 'impl':
#   If it doesn't contain a ' for ' in it, save from the beginning of 'impl' up until '{' (including 'impl', not '{') to a 'impl_block' variable
#   If it contains a ' for ', do the step above but add '<' before and '>' after
#   Remove extras from the line.
#   Example:
#       Git Diff:
#           <impl<T> PartialEq<IncomparableError<T>> for IncomparableError<T>>
#           <impl PartialEq<Error> for Error>
#           <impl fmt::Display for Error>
#       Expected in outputs:
#           <impl PartialEq for IncomparableError<T>>
#           <impl PartialEq for Error>
#           <impl Display for Error>
#
# When we find a line that contains 'fn', check:
#   If the first char on the line is '-', add the name between 'fn' and '(' to a variable named 'fn_name', then append to a 'functions' list by the following rule:
#       If the 2nd and 3rd chars are 'fn', add to list the following matching: '{file_path}.*replace {fn_name}'
#       Else, add to the list the following matching: '{file_path}.*{impl_block}::{fn_name}'
# Then parse through every fn in {functions}, and if the fn matches any line in the files from 'packages-output' folder, remove it

input_file="git.diff"
functions=()

# Read the file line by line
while IFS= read -r line; do
  # Save the file path
  if [[ $line == *'--- a/'* ]]; then
    file_path=$(echo "$line" | cut -c7-)
  fi

  # Save the last impl block
  if [[ "$line" == *'impl'*' for '*'{'* ]]; then
    impl_block="${line#*impl}"
    impl_block="${impl_block%%\ {*}"
    impl_block="<impl$impl_block>" # add 'impl' word, '<' and '>' characters
    impl_block=$(echo "$impl_block" | sed -E 's/(^[^ ]*impl)[^ ]*/\1/') # remove everything after 'impl', until the next space
    impl_block=$(echo "$impl_block" | sed 's/\(<[^<]*\)[^ ]* /\1 /') # remove everything starting with '<' and ending at the next space, from the second word
    impl_block=$(echo "$impl_block" | awk '{sub(/ [^ ]+::/, " "); print}') # keep only the characters after the last '::' of the 2nd word (struct name without path)
  elif [[ "$line" == *'impl'*'{'* ]]; then
    impl_block="${line#*impl}"
    impl_block="${impl_block%%\ {*}"
  elif [[ "$line" == *'trait'*'{'* ]]; then
    impl_block="${line#*trait}"
    impl_block="${impl_block%%\ {*}"
  fi

  # Save the regex matching the file name, impl block (if any), and function to a list
  if [[ $line == *'fn'* ]]; then
    first_char=${line:0:1}
    if [[ $first_char == '-' ]]; then
      fn_name=$(echo "$line" | grep -oP 'fn\s+\K[^(\s]+')
      if [[ ${line:1:1} != " " ]]; then
        # Eg.
        # libsigner/src/http.rs:138:5: replace function_test -> Result...
        # libsigner/src/http.rs:102:32: replace > with < in decode_http_request
        functions+=("${file_path}.*(replace|in) ${fn_name}")
      else
        # Eg.
        # libsigner/src/http.rs:57:9: replace SignerHttpRequest::destruct -> ...
        # libsigner/src/events.rs:255:9: replace <impl EventReceiver for StackerDBEventReceiver>::forward_event -> bool with true
        functions+=("${file_path}.*${impl_block}::${fn_name}")
      fi
    fi
  fi
done < "$input_file"

# Print the lines to be removed
echo "Removing these lines from the stable output:"
for func in "${functions[@]}"; do
  grep -r "$func" ../packages-output/*
done

# Remove the lines matching the regex for all deleted functions
find "../packages-output" -type f -print0 | while IFS= read -r -d $'\0' file; do
  grep -Ev "$(printf '%s\n' "${functions[@]}" | sed 's/\([[].*[]]\)/[\\1]/g')" "$file" > "temp_file" && mv "temp_file" "$file"
  if [[ -e "temp_file" ]]; then
    rm "temp_file"
  fi
done
