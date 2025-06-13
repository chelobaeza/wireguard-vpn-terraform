#!/bin/bash
# This script fetches and displays linked resources for a given EC2 instance ID.
# Requirements: AWS CLI, jq
# Usage: ./get_ec2_linked_info.sh <ec2-instance-id>


INSTANCE_ID="$1"
if [ -z "$INSTANCE_ID" ]; then
  echo "Usage: $0 <ec2-instance-id>"
  exit 1
fi

echo "Fetching data for instance: $INSTANCE_ID"

# Fetch instance data
instance=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --output json | jq -r '.Reservations[0].Instances[0]')

# Extract fields
AMI=$(echo "$instance" | jq -r '.ImageId')
TYPE=$(echo "$instance" | jq -r '.InstanceType')
SUBNET_ID=$(echo "$instance" | jq -r '.SubnetId')
VPC_ID=$(aws ec2 describe-subnets --subnet-ids "$SUBNET_ID" --query "Subnets[0].VpcId" --output text)
SG_IDS=$(echo "$instance" | jq -r '.SecurityGroups[].GroupId' | tr '\n' ' ')
PROFILE_ARN=$(echo "$instance" | jq -r '.IamInstanceProfile.Arn')
PROFILE_NAME=$(basename "$PROFILE_ARN")
KEY_NAME=$(echo "$instance" | jq -r '.KeyName')
VOLUMES=$(echo "$instance" | jq -r '.BlockDeviceMappings[].Ebs.VolumeId')
ENI_IDS=$(echo "$instance" | jq -r '.NetworkInterfaces[].NetworkInterfaceId')

ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name "$PROFILE_NAME" --query "InstanceProfile.Roles[0].RoleName" --output text)

echo ""
echo "📋 Resources ID's:"
echo "--------------------------------------------"

# 1. IAM Role
echo "aws_iam_role=$ROLE_NAME"
# 2. IAM Instance Profile
echo "aws_iam_instance_profile=$PROFILE_NAME"
# 3. Key Pair
echo "aws_key_pair=$KEY_NAME"
# 4. VPC
echo "aws_vpc=$VPC_ID"
# 5. Subnet
echo "aws_subnet=$SUBNET_ID"
# 6. Security Groups
for SG in $SG_IDS; do
  echo "aws_security_group=$SG"
done
# 7. EBS Volumes
for VOL in $VOLUMES; do
  echo "aws_ebs_volume=$VOL"
done
# 8. Elastic IP (optional — check if exists)
EIP_ALLOC_ID=$(aws ec2 describe-addresses --filters "Name=instance-id,Values=$INSTANCE_ID" --query "Addresses[0].AllocationId" --output text 2>/dev/null)
if [ "$EIP_ALLOC_ID" != "None" ] && [ -n "$EIP_ALLOC_ID" ]; then
  echo "aws_eip=$EIP_ALLOC_ID"
fi
# 9. Network Interfaces (if needed)
for ENI in $ENI_IDS; do
  echo "aws_network_interface=$ENI"
done
# 10. EC2 Instance
echo "aws_instance=$INSTANCE_ID"
