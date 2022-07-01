#!/bin/sh
cd src #lol
clang-format -style="{BasedOnStyle: Mozilla, UseTab: Never, IndentWidth: 2, TabWidth: 2, AccessModifierOffset: -2, PointerAlignment: Right}" -verbose -i *.c *.cpp *.h *.hpp