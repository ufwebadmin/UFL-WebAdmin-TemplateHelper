#!/bin/sh

#
# Example: ~/src/UFL-WebAdmin-TemplateHelper/script/wrapper.sh headlines.pl http://news.ufl.edu/research/feed/ /nerdc/www/www.ufl.edu/news/research.html
#

script="$1"
feed="$2"
file="$3"
number="$4"
template="$5"
log="${6:-/dev/null}"

umask 022
cd "$(dirname $0)" &&
    ./"$script" "$feed" "$template" "$number" > "$file.tmp" 2>> "$log" &&
    mv "$file.tmp" "$file"
rm -f "$file.tmp"
