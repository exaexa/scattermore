#!/bin/bash

( cd src
  clang-format -style="{BasedOnStyle: Mozilla, UseTab: Never, IndentWidth: 2, TabWidth: 2, AccessModifierOffset: -2, PointerAlignment: Right}" -verbose -i *.c *.cpp *.h *.hpp
)

find -name '*.c' -or -name '*.cpp' -or -name '*.h' -or -name '*.R' -or -name '*.sh' | while read filename ; do
    # remove any trailing spaces
    sed --in-place -e 's/\s*$//' "$filename"
    # add a final newline if missing
    if [[ -s "$filename" && $(tail -c 1 "$filename" |wc -l) -eq 0 ]]
    then echo >> "$filename"
    fi
    # squash superfluous final newlines
    sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "$filename"
done
