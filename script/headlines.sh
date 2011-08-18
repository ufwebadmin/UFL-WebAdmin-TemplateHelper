#!/bin/sh

#
# Maintained for backwards compatibility with existing cron jobs.
#

feed="$1"
file="$2"
number="$3"
template="$4"
log="${5:-$HOME/cron-logs/headlines.txt}"

if [ "x$template" == "x" ]; then
    template="../root/www.ufl.edu/headlines.html.tmpl"
fi

"$(dirname $0)"/wrapper.sh headlines.pl "$feed" "$file" "$number" "$template" "$log"
