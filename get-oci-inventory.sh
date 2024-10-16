#!/bin/bash

# Function to count compute instances
count_vms() {
  oci compute instance list --compartment-id "$COMPARTMENT_ID" --all --query 'data[].id' --output json | jq '. | length'
}

# Function to count databases
count_databases() {
  oci db system list --compartment-id "$COMPARTMENT_ID" --all --query 'data[].id' --output json | jq '. | length'
}

# Function to count serverless functions (lambdas)
count_functions() {
  oci fn application list --compartment-id "$COMPARTMENT_ID" --all --query 'data[].id' --output json | jq '. | length'
}

# Function to count container clusters (EKS equivalent)
count_eks_clusters() {
  oci ce cluster list --compartment-id "$COMPARTMENT_ID" --all --query 'data[].id' --output json | jq '. | length'
}

# Function to count container instances (Fargate equivalent)
count_fargate() {
  oci compute instance list --compartment-id "$COMPARTMENT_ID" --all --query "data[?\"instance-type\"=='flexible'].id" --output json | jq '. | length'
}

# Fetching the count of each resource
vms=$(count_vms)
databases=$(count_databases)
functions=$(count_functions)
eks_clusters=$(count_eks_clusters)
fargate_instances=$(count_fargate)

# Displaying the results
echo "Total Virtual Machines: $vms"
echo "Total Cloud Databases: $databases"
echo "Total Serverless Functions: $functions"
echo "Total Container Hosts: $eks_clusters"
echo "Total Serverless Containers: $fargate_instances"

