# Data source to get all route tables for the VPC
data "aws_route_tables" "vpc" {
  vpc_id = var.vpc_id
}

# VPC Peering Connection Request to Third-Party VPC
resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_owner_id
  peer_region   = var.peer_region

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vpc-peering"
    }
  )
}

# VPC Peering Connection Options (Requester Side)
# Note: This will be applied once the connection is accepted by the third party
# May need to re-run terraform apply after the third party accepts the connection
resource "aws_vpc_peering_connection_options" "requester" {
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  requester {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }
}

# Routes to the peer VPC
# Routes are created immediately but only become functional once the third party accepts the connection
resource "aws_route" "peer" {
  for_each = {
    for pair in setproduct(data.aws_route_tables.vpc.ids, var.peer_cidr_blocks) :
    "${pair[0]}-${replace(pair[1], "/[^a-zA-Z0-9]/", "-")}" => {
      route_table_id = pair[0]
      cidr_block     = pair[1]
    }
  }

  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
