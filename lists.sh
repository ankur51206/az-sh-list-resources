#!/bin/bash

az account set --subscription "xxxxxxxxx-xxx-xxxx-xxxx-xxxxxxxxx"

# Define column widths
rg_width=30
resource_name_width=40
resource_type_width=40
resource_kind_width=20

# Print the table headers
printf "%-${rg_width}s %-${resource_name_width}s %-${resource_type_width}s %-${resource_kind_width}s\n" "Resource Group" "Resource Name" "Resource Type" "Resource Kind"

# Separator line
printf "%-${rg_width}s %-${resource_name_width}s %-${resource_type_width}s %-${resource_kind_width}s\n" "------------------" "----------------" "----------------" "----------------"

# Get a list of all resource groups
resourceGroups=$(az group list --query '[].name' --output tsv)

# Iterate through each resource group
for rg in $resourceGroups; do

    # Get a list of resources in the current resource group
    resources=$(az resource list --resource-group $rg --query '[].{ResourceGroup:resourceGroup, Name:name, Type:type, Kind:kind}' --output tsv)

    # Iterate through each resource and display it in tab-separated format
    while read -r line; do
        resource_name=$(echo "$line" | awk -F$'\t' '{print $2}') # Extract resource name from the line
        resource_type=$(echo "$line" | awk -F$'\t' '{print $3}') # Extract resource type from the Type column
        resource_kind=$(echo "$line" | awk -F$'\t' '{split($3, a, "/"); print a[length(a)]}') # Extract the last segment as resource kind
        printf "%-${rg_width}s %-${resource_name_width}s %-${resource_type_width}s %-${resource_kind_width}s\n" "$rg" "$resource_name" "$resource_type" "$resource_kind"
    done <<< "$resources"
done
