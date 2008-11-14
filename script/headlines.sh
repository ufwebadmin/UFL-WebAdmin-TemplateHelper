#!/bin/sh

feed="$1"
file="$2"
number="$3"
template="../root/www.ufl.edu/headlines.html.tmpl"
log="$HOME"/log/headlines.txt

cd "$(dirname $0)" &&
    ./headlines.pl "$feed" "$template" "$number" > "$file.tmp" 2>> "$log" &&
    mv "$file.tmp" "$file"
rm -f "$file.tmp"
