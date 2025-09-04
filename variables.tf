variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC (requester) where the peering connection will originate"
  type        = string
}

variable "route_table_ids" {
  description = "List of route table IDs where routes to the peer VPC will be created"
  type        = list(string)
  default     = []
}

variable "peer_vpc_id" {
  description = "The ID of the third-party VPC (accepter) to peer with"
  type        = string
}

variable "peer_owner_id" {
  description = "The AWS account ID of the third-party VPC owner"
  type        = string
}

variable "peer_region" {
  description = "The region of the third-party VPC"
  type        = string
}

variable "peer_cidr_blocks" {
  description = "List of CIDR blocks of the third-party VPC for routing"
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.peer_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All peer_cidr_blocks must be valid CIDR blocks"
  }
}

variable "allow_remote_vpc_dns_resolution" {
  description = "Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
