#!/bin/bash

# Replace these variables with your actual database connection details
HOST="127.0.0.1"
PORT=30306
USER="root"
PASSWORD="password"
DATABASE="blue_green"

# SQL command to fetch all greetings
SQL_QUERY="SELECT greeting FROM greetings;"

# Execute the query and capture the output
OUTPUT=$(mysql -h "$HOST" -P "$PORT" -u "$USER" -p"$PASSWORD" "$DATABASE" -e "$SQL_QUERY" --ssl-mode=DISABLED)

# Check for success
if [ $? -eq 0 ]; then
    if [ -z "$OUTPUT" ]; then
        echo "Query executed successfully, but no data was returned."
    else
        echo $'Query executed successfully. Output:\n'
        echo "$OUTPUT"
    fi
else
    echo $'Failed to execute query. Error:\n'
    echo "$OUTPUT"
fi

read -rsp $'\nScript end.'