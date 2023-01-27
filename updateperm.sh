#!/bin/sh

# The base URL for the lists of nodes in the Alastria Github repository 
BASE_URL="https://raw.githubusercontent.com/alastria/alastria-node-quorum-directory/main/"

# The CONFIG directory where we should create the input permissioning files
CONFIG_DIR="config"

# Download from Alastria Github the lists of Validator, Regular and Boot nodes
download_permissioned_lists() {

    wget -nv -O ${CONFIG_DIR}/directory.val ${BASE_URL}directory.val
    if [ $? != 0 ]; then echo "Error downloading directory.val"; return 1; fi

    wget -nv -O ${CONFIG_DIR}/directory.reg ${BASE_URL}directory.reg
    if [ $? != 0 ]; then echo "Error downloading directory.reg"; return 1; fi

    wget -nv -O ${CONFIG_DIR}/directory.bot ${BASE_URL}directory.bot
    if [ $? != 0 ]; then echo "Error downloading directory.bot"; return 1; fi

    return 0
}

# print_file prints to stdout the second field of each line
# Lines are terminated by a semicolon and a carriage return
print_file() {
    awk '{ printf "\"" $2 "\",\n" }' $1
    return 0
}

# print_last_file is like print_file but the last item does not have a semicolon at the end
# Lines are terminated by a semicolon and a carriage return, except the last one
print_last_file() {
    awk 'FNR == 1 { printf "\"" $2 "\"" }
        FNR != 1 { printf ",\n\"" $2 "\"" }
        END { printf "\n" }' $1
    return 0
}

# Create the config directory if it does not exist
mkdir -p $CONFIG_DIR

# Download the lists from the Github repository
download_permissioned_lists

# Generate the permissioning list for Validator nodes
# It should be formatted as a JSON array (where the last item DOES NOT have a semicolon at the end of the line)
OUTPUT_FILE=${CONFIG_DIR}/validator_permissioned.json
# Validators are connected to Validators + Boot nodes
printf '[\n' > $OUTPUT_FILE
print_file ${CONFIG_DIR}/directory.val >> $OUTPUT_FILE
print_last_file ${CONFIG_DIR}/directory.bot >> $OUTPUT_FILE
printf ']\n' >> $OUTPUT_FILE
echo "$OUTPUT_FILE file created"

# Generate the permissioning list for Regular nodes
# It should be formatted as a JSON array (where the last item DOES NOT have a semicolon at the end of the line)
OUTPUT_FILE=${CONFIG_DIR}/regular_permissioned.json
# Regulars are connected only to Boot nodes
printf '[\n' > $OUTPUT_FILE
print_last_file ${CONFIG_DIR}/directory.bot >> $OUTPUT_FILE
printf ']\n' >> $OUTPUT_FILE
echo "$OUTPUT_FILE file created"

# Generate the permissioning list for Boot nodes
# It should be formatted as a JSON array (where the last item DOES NOT have a semicolon at the end of the line)
OUTPUT_FILE=${CONFIG_DIR}/boot_permissioned.json
# Boot nodes are connected to all nodes: Validators, Boot and Regular nodes
printf '[\n' > $OUTPUT_FILE
print_file ${CONFIG_DIR}/directory.val >> $OUTPUT_FILE
print_file ${CONFIG_DIR}/directory.bot >> $OUTPUT_FILE
print_last_file ${CONFIG_DIR}/directory.reg >> $OUTPUT_FILE
printf ']\n' >> $OUTPUT_FILE
echo "$OUTPUT_FILE file created"
