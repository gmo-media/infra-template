# Enable if you want to connect to another VPC
# data "aws_vpc" "other" {
#   id = "vpc-abcdef"
# }
#
# resource "aws_vpc_peering_connection" "peering" {
#   vpc_id      = module.vpc.vpc_id
#   peer_vpc_id = data.aws_vpc.other.id
#   auto_accept = true
# }
#
# resource "aws_route" "private-peering" {
#   for_each = toset(module.vpc.private_route_table_ids)
#
#   route_table_id            = each.key
#   destination_cidr_block    = data.aws_vpc.other.cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
# }
#
# resource "aws_route" "public-peering" {
#   for_each = toset(module.vpc.public_route_table_ids)
#
#   route_table_id            = each.key
#   destination_cidr_block    = data.aws_vpc.other.cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
# }
