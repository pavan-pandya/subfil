#!/bin/bash

# Ask user for the input file
read -p "Enter the filename containing the list of domains: " INPUT_FILE

# Check if the file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Output files in current directory
WORKING_FILE="$PWD/working_domains.txt"
NON_WORKING_FILE="$PWD/non_working_domains.txt"
REDIRECTED_FILE="$PWD/redirected_domains.txt"

# Clear previous results
> "$WORKING_FILE"
> "$NON_WORKING_FILE"
> "$REDIRECTED_FILE"

echo -e "\n🔍 Checking domains from '$INPUT_FILE'...\n"

# Loop through each domain and check status
while IFS= read -r domain; do
    # Get HTTP status code only (follow redirects)
    response=$(curl -Is --connect-timeout 5 "https://$domain" | head -n 1)

    if echo "$response" | grep -q "HTTP/[12] 30[1237]"; then
        echo "$domain is REDIRECTING 🔁 ($response)"
        echo "$domain" >> "$REDIRECTED_FILE"
    elif echo "$response" | grep -q "HTTP/[12] 200"; then
        echo "$domain is WORKING ✅"
        echo "$domain" >> "$WORKING_FILE"
    else
        echo "$domain is NOT WORKING ❌ ($response)"
        echo "$domain" >> "$NON_WORKING_FILE"
    fi
done < "$INPUT_FILE"

# Final message
echo -e "\n✅ Check complete! Results saved in:"
echo "  - $WORKING_FILE (Working Domains)"
echo "  - $NON_WORKING_FILE (Non-Working Domains)"
echo "  - $REDIRECTED_FILE (Redirected Domains)"
