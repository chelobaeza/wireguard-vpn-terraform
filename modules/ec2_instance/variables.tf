variable "name" {
  description = "Base name for all resources."
  type        = string
}

variable "ami" {
  description = "AMI ID to use."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "SSH key pair name."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID for the security group."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
