#!/bin/sh

feed="$1"
file="$2"
number="$3"
template="$4"

if [ "x$template" == "x" ]; then
    template="../root/www.ufl.edu/headlines.html.tmpl"
fi

log="$HOME"/log/headlines.txt

umask 022
cd "$(dirname $0)" &&
    ./headlines.pl "$feed" "$template" "$number" > "$file.tmp" 2>> "$log" &&
    mv "$file.tmp" "$file"
rm -f "$file.tmp"
