output "peering_connection_id" {
  description = "The ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.this.id
}

output "peer_vpc_info" {
  description = "Information about the peer VPC"
  value = {
    vpc_id      = var.peer_vpc_id
    owner_id    = var.peer_owner_id
    region      = var.peer_region
    cidr_blocks = var.peer_cidr_blocks
  }
}

output "routes_created" {
  description = "Map of routes created for the peering connection"
  value = {
    for key, route in aws_route.peer : key => {
      route_table_id = route.route_table_id
      cidr_block     = route.destination_cidr_block
    }
  }
}