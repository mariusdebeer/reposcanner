#!/bin/bash
# Author: MDB
# Function: Recursively searches a given repository URL for a specified RPM file,
#           traversing all valid subdirectories and printing the full URLs of any
#           matching files found. Excludes external mirror links and non-directory
#           paths, with single-line progress output.
# Usage:   ./findrpm.sh <repoURL> <rpm file>
# Example: Example: $0 https://vault.centos.org/ agg-2.5-18.el7.i686.rpm

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <repo_url> <rpm_file>"
    echo "Example: $0 https://vault.centos.org/ agg-2.5-18.el7.i686.rpm"
    exit 1
fi

REPO_URL="$1"
RPM_FILE="$2"

# Ensure URL ends with a single slash
REPO_URL="${REPO_URL%/}/"

# Function to URL encode a string
urlencode() {
    local string="$1"
    local encoded=""
    local pos c o
    for (( pos=0 ; pos<${#string} ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="$c" ;;
            * )               printf -v o '%%%02x' "'$c"
        esac
        encoded+="$o"
    done
    echo "$encoded"
}

# Function to check if a URL is accessible
check_url() {
    local url="$1"
    # Normalize URL by replacing multiple slashes with a single slash
    url=$(echo "$url" | sed 's/\/\+/\//g')
    curl --silent --head --fail --max-time 5 "$url" >/dev/null 2>&1
    return $?
}

# Function to extract valid relative directories from HTML listing
get_directories() {
    local url="$1"
    # Extract hrefs ending in '/', exclude parent/current dir, non-relative paths, and external mirrors
    curl -s "$url" | grep -oE 'href="[^"]*/"' | sed 's/href="//' | sed 's/"//' | grep -vE "^\.\./?$" | grep -E '^[a-zA-Z0-9._-]+/$' | grep -vE "^(https?|rsync|ftp)://" | grep -vE "^(archive\.kernel\.org|linuxsoft\.cern\.ch|mirror\.nsc\.liu)/$"
}

# Function to search for RPM file recursively
search_rpm() {
    local current_url="$1"
    local depth="$2"
    
    # Normalize current_url by replacing multiple slashes with a single slash
    current_url=$(echo "$current_url" | sed 's/\/\+/\//g')
    
    # Print current directory being searched (overwrites previous line)
    printf "\rSearching in: %s" "$current_url"
    
    # Encode the RPM filename for URL
    local encoded_rpm
    encoded_rpm=$(urlencode "$RPM_FILE")
    
    # Check if the RPM file exists at the current URL
    if check_url "${current_url}${encoded_rpm}"; then
        printf "\nFound: %s%s\n" "$current_url" "$RPM_FILE"
    fi
    
    # Get all directories at current level
    local dirs
    dirs=$(get_directories "$current_url")
    
    # Recursively search through each directory
    while IFS= read -r dir; do
        if [ -n "$dir" ]; then
            search_rpm "${current_url}${dir}" $((depth + 1))
        fi
    done <<< "$dirs"
}

# Start the search from the root URL
echo "Searching for $RPM_FILE in $REPO_URL..."
search_rpm "$REPO_URL" 0

# Clear the searching line and check if any files were found
printf "\r\033[K"
if [ -z "$(get_directories "$REPO_URL")" ] && ! check_url "${REPO_URL}${RPM_FILE}"; then
    echo "No instances of $RPM_FILE found in $REPO_URL"
fi
