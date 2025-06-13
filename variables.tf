variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where the resources will be deployed."
  type        = string    
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched."
  type        = string  
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "SSH key pair name."
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance."
  type        = string
}