#!/bin/bash

# Usage:
# bash txt2hoc.sh input.txt output.hoc

# Set options:

# Fail on a single failed command in a pipeline
set -o pipefail

# Fail on error and undefined variables
set -eu

# Count number of sections
num_sections=$(grep -c "#" $1)

# Reformats measurement lines to pt3dadd format and removes extra text
sed '1,/#/d' $1 | awk '{ $1=""; $2="pt3dadd("; $6=",1)"; $7=""; print $2$3","$4","$5$6}' | sed -r 's/ {1,}/,/g' > temp1.txt

# Replaces original # lines (which now read "pt3dadd(,,,1) with text to define section
awk '/pt3dadd\(,,,1\)/{gsub("pt3dadd","}\naccess sections["++p"]\nUndefined.append()\nsections["p"] { ");} 1' temp1.txt > temp2.txt

# Remove unecessary (,,,1) text. Should be able to do this as part of the previous awk command but couldn't work how
sed -i 's/ (,,,1)$//' temp2.txt

# Add start of file text
echo -e "objref Undefined\nUndefined = new SectionList()\ncreate sections[$num_sections]\n}\naccess sections[0]\nUndefined.append()\nsections[0] {" | cat - temp2.txt > $2

# Add missing bracket to end of file
echo } >> $2

# Remove temporary files
rm temp1.txt
rm temp2.txt
