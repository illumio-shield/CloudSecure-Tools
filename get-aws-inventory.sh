#!/bin/bash
# to run, pre-req is to run "aws configure" with user's AWS API keys
# then just type ./get-aws-inventory.sh 
# -----------------------------------------------------------------------------
# current inventory list is limited to EC2, RDS, EKS clusters, lambda functions.
# for more capability, add aws cli commands for the desired resource
# commented out kubectl commands as additional kubeconfig steps are required


# List all AWS regions using AWS CLI
regions=$(aws ec2 describe-regions --output json | jq -r '.Regions[].RegionName')

# Initialize counters
total_ec2=0
total_rds=0
total_vpcs=0
total_lambda=0
total_eks_clusters=0
total_fargate_count=0
total_pods=0
total_nodes=0

# Iterate through each region
for region in $regions; do
    echo "Region: $region"

    # List EC2 instances and count
    ec2_count=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceType' --output text --region $region | wc -w)
    total_ec2=$((total_ec2 + ec2_count))
    echo "EC2 Instances: $ec2_count"

    # List RDS instances and count
    rds_count=$(aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text --region $region | wc -w)
    total_rds=$((total_rds + rds_count))
    echo "RDS Instances: $rds_count"

    # List VPCs and count
    vpc_count=$(aws ec2 describe-vpcs --query 'Vpcs[].VpcId' --output text --region $region | wc -w)
    total_vpcs=$((total_vpcs + vpc_count))
    echo "VPCs: $vpc_count"

    # List Lambda functions and count
    lambda_count=$(aws lambda list-functions --query 'Functions[].FunctionName' --output text --region $region | wc -w)
    total_lambda=$((total_lambda + lambda_count))
    echo "Lambda Functions: $lambda_count"

    # List EKS clusters and count
    eks_clusters=$(aws eks list-clusters --output json --region $region | jq -r '.clusters[]')
    eks_cluster_count=0
    eks_pod_count=0
    eks_node_count=0

    for eks_cluster in $eks_clusters; do
	#List Fargates
        fargate_count=$(aws eks list-fargate-profiles --cluster-name $eks_cluster --output text --query 'fargateProfileNames' --region $region | wc -w)
        eks_cluster_count=$((eks_cluster_count + 1))
    done

    total_eks_clusters=$((total_eks_clusters + eks_cluster_count))
    total_fargate_count=$((total_fargate_count + fargate_count))
    total_pods=$((total_pods + eks_pod_count))
    total_nodes=$((total_nodes + eks_node_count))

    echo "EKS Clusters: $eks_cluster_count"
    echo "Fargate: $fargate_count"
    echo "-----------------------"
done

# Display summary
echo "Summary Across All Regions:"
echo "-----------------------"
echo "Total EC2 Instances: $total_ec2"
echo "Total RDS Instances: $total_rds"
echo "Total VPCs: $total_vpcs"
echo "Total Lambda Functions: $total_lambda"
echo "Total EKS Clusters: $total_eks_clusters"
echo "Total Fargate Count: $total_fargate_count"
