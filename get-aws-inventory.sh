#!/bin/bash
# To run, pre-req is to export an environment variable AWS_CONFIG_PATH, with location to .aws directory containing credentials and config file.
# This script will run "aws configure" with user's AWS API keys for all profiles mentioned in '.aws/config' file.
# To run just type ./get-aws-inventory.sh 
# -----------------------------------------------------------------------------
# current inventory list is limited to EC2, RDS, EKS clusters, lambda functions.
# for more capability, add aws cli commands for the desired resource
# commented out kubectl commands as additional kubeconfig steps are required

# Initialize counters
total_ec2=0
total_rds=0
total_lambda=0
total_eks_clusters=0
total_fargate_count=0
total_pods=0
total_nodes=0
# Read aws profiles and run 'aws configure'

profiles=$(awk -F 'profile ' '/\[profile/ {print $2}' $AWS_CONFIG_PATH/config | cut -d']' -f1)
for profile in $profiles; do
    echo "***********************"
    echo "Profile: $profile"
    echo "***********************"
    export AWS_PROFILE=$profile
    # Get access keys from $AWS_CONFIG_PATH/credentials file
    aws_access_key_id=$(awk -v profile="$profile" -F ' = ' '$1 == "aws_access_key_id" && found {print $2; exit} $1 == "[" profile "]" {found=1}' $AWS_CONFIG_PATH/credentials)
    aws_secret_access_key=$(awk -v profile="$profile" -F ' = ' '$1 == "aws_secret_access_key" && found {print $2; exit} $1 == "[" profile "]" {found=1}' $AWS_CONFIG_PATH/credentials)
    aws configure --profile $profile set aws_access_key_id $aws_access_key_id
    aws configure --profile $profile set aws_secret_access_key $aws_secret_access_key 

# List all AWS regions using AWS CLI
regions=$(aws ec2 describe-regions --output json | jq -r '.Regions[].RegionName')
printf "%-20s %-20s %-20s %-20s %-20s %-20s\n" "region" "virtualMachines" "cloudDatabases" "serverlessFunctions" "containerHosts" "serverlessContainers"
# Iterate through each region
for region in $regions; do
   # echo "Region: $region"

    # List EC2 instances and count
    ec2_count=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceType' --output text --region $region | wc -w)
    total_ec2=$((total_ec2 + ec2_count))
    #echo "Virtual Machines:\t\t$ec2_count"
    #printf "Virtual Machines:\t\t$ec2_count\n"
    # List RDS instances and count
    rds_count=$(aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text --region $region | wc -w)
    total_rds=$((total_rds + rds_count))
    #printf "Cloud Databases:\t\t$rds_count\n"

    # List Lambda functions and count
    lambda_count=$(aws lambda list-functions --query 'Functions[].FunctionName' --output text --region $region | wc -w)
    total_lambda=$((total_lambda + lambda_count))
    #printf "Serverless Functions:\t\t$lambda_count\n"

    # List EKS clusters and count
    eks_clusters=$(aws eks list-clusters --output json --region $region | jq -r '.clusters[]')
    eks_cluster_count=0
    eks_pod_count=0
    eks_node_count=0
    fargate_count=0
    for eks_cluster in $eks_clusters; do
	#List Fargates
        fargate_count=$(aws eks list-fargate-profiles --cluster-name $eks_cluster --output text --query 'fargateProfileNames' --region $region | wc -w)
        eks_cluster_count=$((eks_cluster_count + 1))
    done

    total_eks_clusters=$((total_eks_clusters + eks_cluster_count))
    total_fargate_count=$((total_fargate_count + fargate_count))
    total_pods=$((total_pods + eks_pod_count))
    total_nodes=$((total_nodes + eks_node_count))

    #printf "Container Hosts:\t\t\t$eks_cluster_count\n"
    #printf "Serverless Containers:\t\t\t$fargate_count\n"
    printf "%-20s %-20s %-20s %-20s %-20s %-20s\n" "$region" "$ec2_count" "$rds_count" "$lambda_count" "$eks_cluster_count" "$fargate_count"
    #echo "-----------------------"
done
done
# Display summary



echo "Summary Across All Regions:"
echo "-----------------------"
echo "Total Virtual Machines: $total_ec2"
echo "Total Cloud Databases: $total_rds"
echo "Total Serverless Functions: $total_lambda"
echo "Total Container Hosts: $total_eks_clusters"
echo "Total Serverless Containers: $total_fargate_count"
