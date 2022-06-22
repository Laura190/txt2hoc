#!/bin/bash

# Usage:
# bash txt2hoc.sh input.txt output.hoc

# Set options:

# Fail on a single failed command in a pipeline
set -o pipefail

# Fail on error and undefined variables
set -eu

# Remove multiple spaces from file
tr -s " " < $1 > temp.txt

# Count number of sections
num_sections=$(grep -c "#" temp.txt)

# Begin output file
echo "objref Undefined" > $2
echo "Undefined = new SectionList()" >> $2
echo "create sections[$num_sections]" >> $2

# Reformat .txt to .hoc
count=0
while IFS= read -r line; do
if [[ $line == [0-9]* ]]; then
if [[ $line == "#"* ]]; then
if [[ $count != 0 ]]; then
echo "}" >> $2
echo  >> $2
fi
echo "access sections[$count]" >> $2
echo "Undefined.append()" >> $2
echo "sections[$count] {" >> $2
count=$(($count+1))
else
x=$(echo "$line" | cut -d " " -f 3)
y=$(echo "$line" | cut -d " " -f 4)
z=$(echo "$line" | cut -d " " -f 5)
echo "	pt3dadd($x, $y, $z, 1)" >> $2
fi
fi
done < temp.txt
echo "}" >> $2
echo  >> $2
rm temp.txt
