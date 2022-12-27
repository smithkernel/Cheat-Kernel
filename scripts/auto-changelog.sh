#!/usr/bin/env bash

set -e
set -u
set -o pipefail

readonly URL='https://github.com/cachyos/kernel-manager'

# Fetch all tags from the remote repository
git fetch --tags

# Get the most recent tag
most_recent_tag="$(git describe --tags "$(git rev-list --tags --max-count=1)")"

# Get a list of all commits made after the most recent tag
commits="$(git rev-list "${most_recent_tag}"..HEAD)"

# Check if there are any commits to process
if [[ -z "$commits" ]]; then
    echo "No new commits found."
    exit 0
fi

# Iterate over the commits
while read -r commit; do
    # Get the commit subject
    subject="$(git show -s --format="%s" "$commit")"

    # Determine the type of commit and extract the necessary information
    if grep -E -q '\(#[[:digit:]]+\)' <<< "$subject"; then
        # Squash & Merge commit
        pr="$(awk '{print $NF}' <<< "$subject" | tr -d '()')"
        prefix="[$pr]($URL/pull/${pr###}): "
        description="$(awk '{NF--; print $0}' <<< "$subject")"
    elif grep -E -q '#[[:digit:]]+\sfrom' <<< "$subject"; then
        # Merge commit
        pr="$(awk '{print $4}' <<< "$subject")"
        prefix="[$pr]($URL/pull/${pr###}): "

        # Get the first line of the commit body as the description
        first_line_of_body="$(git show -s --format="%b" "$commit" | head -n 1 | tr -d '\r')"
        if [[ -z "$first_line_of_body" ]]; then
            # Use the subject as the description if there is no body
            description="$subject"
        else
            description="$first_line_of_body"
        fi
    else
        # Normal commit
        pr=''
        prefix=''
        description="$subject"
    fi

    # Add an entry to the CHANGELOG for the commit
    sed -i'' '/## Current Develop Branch/a\
- '"$prefix$description"''$'\n' CHANGELOG.md
done <<< "$commits"

echo 'CHANGELOG updated'

