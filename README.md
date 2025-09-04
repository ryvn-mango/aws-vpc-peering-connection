# AWS VPC Peering Connection Module

A Terraform module for establishing VPC peering connections with third-party AWS accounts.

## Purpose

This module creates VPC peering connection requests to third-party VPCs and manages the associated route table entries. It's specifically designed for cross-account peering scenarios where the accepter VPC is owned by a third party.

## Usage

```hcl
module "third_party_peering" {
  source = "./aws-vpc-peering-connection"
  
  name_prefix = "vendor"
  vpc_id      = "vpc-12345678"  # Routes will be added to all route tables in this VPC
  
  # These values are provided by the third party
  peer_vpc_id      = "vpc-87654321"
  peer_owner_id    = "123456789012"
  peer_region      = "us-east-1"
  peer_cidr_blocks = ["10.0.0.0/16"]
  
  allow_remote_vpc_dns_resolution = true
  
  tags = {
    Environment = "production"
    Partner     = "ExternalVendor"
  }
}
```

## Workflow

1. **Request Connection**: Apply this module to create a peering connection request
2. **Share Connection ID**: Provide the `peering_connection_id` output to the third party
3. **Third Party Accepts**: The third party accepts the connection in their AWS account
4. **Routes Activate**: Once accepted, the routes become active and traffic can flow

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Prefix for resource names | `string` | - | yes |
| `vpc_id` | Your VPC ID (routes will be added to all route tables in this VPC) | `string` | - | yes |
| `peer_vpc_id` | Third-party VPC ID | `string` | - | yes |
| `peer_owner_id` | Third-party AWS account ID | `string` | - | yes |
| `peer_region` | Third-party VPC region | `string` | - | yes |
| `peer_cidr_blocks` | Third-party CIDR blocks for routing | `list(string)` | - | yes |
| `allow_remote_vpc_dns_resolution` | Enable DNS resolution across peering | `bool` | `true` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `peering_connection_id` | VPC peering connection ID (share with third party) |
| `connection_status` | Current connection status |
| `accept_status` | Connection acceptance status |
| `peer_vpc_info` | Peer VPC details |
| `routes_created` | Routes created for the peering connection |

## Example Workflow

When setting up VPC peering with a third-party service:

1. Request VPC peering details from the third party
2. They provide:
   - VPC ID
   - AWS Account ID
   - Region
   - CIDR blocks
3. Use this module with the provided values
4. Share the `peering_connection_id` with the third party
5. Third party accepts the connection in their AWS account
6. Routes automatically become active

## Notes

- This module is designed for **cross-account** peering only
- Routes are automatically added to **all route tables** in the VPC
- Routes are created immediately but only function after acceptance
- DNS resolution can be enabled for private hostname resolution
- The module creates routes for all combinations of route tables and CIDR blocks

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Kubernetes backend (configured separately)