#!/bin/bash

find -name '*.c' -or -name '*.h' -or -name '*.R' | while read filename ; do
    # remove any trailing spaces
    sed --in-place -e 's/\s*$//' "$filename"
    # add a final newline if missing
    if [[ -s "$filename" && $(tail -c 1 "$filename" |wc -l) -eq 0 ]]
    then echo >> "$filename"
    fi
    # squash superfluous final newlines
    sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "$filename"
done