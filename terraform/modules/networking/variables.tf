variable "name" {
  description = "VPC Name tag. Exam requires project-bedrock-vpc."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to span (minimum two)."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name, used for subnet discovery tags."
  type        = string
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway (exam cost guardrail)."
  type        = bool
}

variable "tags" {
  description = "Extra tags merged onto VPC resources."
  type        = map(string)
  default     = {}
}
