#!/bin/bash

# Set the output file path
output_file="resource_list.csv"

az account set --subscription "xxxxx-xxx-xxxx-xxxx-xxxxxxxx"

# Define column headers
header="Resource Group,Resource Name,Resource Type,Resource Kind"

# Initialize the output file with headers
echo "$header" > "$output_file"

# Get a list of all resource groups
resourceGroups=$(az group list --query '[].name' --output tsv)

# Iterate through each resource group
for rg in $resourceGroups; do

    # Get a list of resources in the current resource group
    resources=$(az resource list --resource-group $rg --query '[].{ResourceGroup:resourceGroup, Name:name, Type:type, Kind:kind}' --output tsv)

    # Iterate through each resource and append it to the output file in CSV format
    while read -r line; do
        resource_name=$(echo "$line" | awk -F$'\t' '{print $2}') # Extract resource name from the line
        resource_type=$(echo "$line" | awk -F$'\t' '{print $3}') # Extract resource type from the Type column
        resource_kind=$(echo "$line" | awk -F$'\t' '{split($3, a, "/"); print a[length(a)]}') # Extract the last segment as resource kind
        echo "$rg,$resource_name,$resource_type,$resource_kind" >> "$output_file"
    done <<< "$resources"
done

echo "Output saved to $output_file"
