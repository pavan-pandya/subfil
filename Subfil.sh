#!/bin/bash

# Ask user for the input file
read -p "Enter the filename containing the list of domains: " INPUT_FILE

# Check if the file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Output files
WORKING_FILE="working_domains.txt"
NON_WORKING_FILE="non_working_domains.txt"

# Clear previous results
> "$WORKING_FILE"
> "$NON_WORKING_FILE"

echo -e "\n🔍 Checking domains from '$INPUT_FILE'...\n"

# Loop through each domain and check status
while IFS= read -r domain; do
    if curl --connect-timeout 5 -Is "https://$domain" | head -n 1 | grep -q "HTTP/[12]"; then
        echo "$domain is WORKING ✅"
        echo "$domain" >> "$WORKING_FILE"
    else
        echo "$domain is NOT WORKING ❌"
        echo "$domain" >> "$NON_WORKING_FILE"
    fi
done < "$INPUT_FILE"

echo -e "\n✅ Check complete! Results saved in:"
*echo "  - $WORKING_FILE (Working Domains)"
echo "  - $NON_WORKING_FILE (Non-Working Domains)"