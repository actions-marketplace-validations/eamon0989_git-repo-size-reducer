#!/bin/sh -l

# Exit immediately if any command fails
set -e

# Function to calculate size of repository
calculate_size() {
  git count-objects -v | awk '/size:/ {print $2; size_pack_found=1} /size-pack:/ {print $2; size_pack_found=1} END {if(!size_pack_found) print "0"}' | paste -sd+ - | bc
}

# Define variables
WORKSPACE=/github/workspace
FILES_TO_DELETE=$WORKSPACE/files-to-delete.txt

# Copy necessary files to the workspace
cp ../../get-files-to-delete.mjs $WORKSPACE/get-files-to-delete.mjs
cp ../../package.json $WORKSPACE/package.json
cp ../../package-lock.json $WORKSPACE/package-lock.json

# Analyze repository and get initial size
git filter-repo --analyze
npm ci
totalPreviousSize=$(calculate_size)

# Get files to delete and calculate new size
node $WORKSPACE/get-files-to-delete.mjs
git filter-repo --invert-paths --paths-from-file $FILES_TO_DELETE --force
totalNewSize=$(calculate_size)

# Calculate size difference and display results
sizeDifference=$(echo "$totalPreviousSize - $totalNewSize" | bc)
echo "Your repo previously contained $(echo "$totalPreviousSize / 1024" | bc) megabytes or $(echo "$totalPreviousSize") kilobytes of objects."
echo "It now contains $(echo "$totalNewSize / 1024" | bc) megabytes or $(echo "$totalNewSize") kilobytes of objects."
echo "You have filtered $(echo "$sizeDifference / 1024" | bc) megabytes or $(echo "$sizeDifference") kilobytes of objects from your git repository."
