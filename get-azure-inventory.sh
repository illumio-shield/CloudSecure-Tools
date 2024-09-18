#!/bin/bash
# Run this from powershell/bash shell in Azure console
# Azure subscription details

#subscription_id=$1
# Initialize counters
total_vms=0
total_sqs=0
total_functions=0
total_aks_clusters=0
total_aci=0

subscriptions=$(az account list --query [].id --output tsv)

for subscription in $subscriptions; do

function_count=0
vm_count=0
sql_count=0
aks_count=0
aci_count=0
# Set the default subscription
az account set --subscription $subscription

echo "***********************"
echo " Subscription $subscription "
echo "***********************"

vm_count=$(az resource list --resource-type "Microsoft.Compute/virtualMachines" --query "[].{Name:name}" --output tsv | wc -l)
echo "Virtual Machines: $vm_count"
total_vms=$((total_vms + vm_count))

sql_count=$(az resource list --resource-type "Microsoft.Sql/servers" --query "[].{Name:name}" --output tsv | wc -l)
echo "SQL Databases:	$sql_count"

cosmosdb_count=$(az resource list --resource-type "Microsoft.DocumentDB/databaseAccounts" --query "[].{Name:name}" --output tsv | wc -l)
echo "Cosmos Databases:  $cosmosdb_count"
total_sqs=$((total_sqs + sql_count + cosmosdb_count))

function_count=$(az resource list --resource-type Microsoft.Web/sites --query "[?type=='Microsoft.Web/sites' && contains(name, 'functionapp')]" --output tsv | wc -l)
echo "Serverless Functions: $function_count"
total_functions=$((total_functions + function_count))

aks_count=$(az resource list --resource-type "Microsoft.ContainerService/managedClusters" --query "[].{Name:name}" --output tsv | wc -l)
echo "Container Hosts: $aks_count"
total_aks_clusters=$((total_aks_clusters + aks_count))

aci_count=$(az resource list --resource-type "Microsoft.ContainerInstance/containerGroups" --query "[].{Name:name}" --output tsv | wc -l)
echo "Serverless Containers: $aci_count"
total_aci=$((total_aci + aci_count))
done

# Display summary
echo "-----------------------"
echo "Summary Across All Regions:"
echo "-----------------------"
echo "Total Virtual Machines: $total_vms"
echo "Total Cloud Databases: $total_sqs"
echo "Total Serverless Functions: $total_functions"
echo "Total Container Hosts: $total_aks_clusters"
echo "Total Serverless Containers: $total_aci"
