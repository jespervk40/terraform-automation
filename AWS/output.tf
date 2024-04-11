# # Allocate Elastic IP
# resource "aws_eip" "my_eip" {
#   instance = aws_instance.my_ec2_instance.id
# }

# # Output variables
# output "vpc_id" {
#   value = aws_vpc.my_vpc.id
# }

# output "subnet_id" {
#   value = aws_subnet.my_subnet.id
# }

# output "security_group_id" {
#   value = aws_security_group.my_security_group.id
# }

# output "public_ip" {
#   value = aws_instance.my_ec2_instance.public_ip
# }

# output "private_ip" {
#   value = aws_instance.my_ec2_instance.private_ip
# }
# output "gateway_id" {
#   value = aws_internet_gateway.my_igw.id
# }
# output "route_table_id" {
#   value = aws_route_table.my_route_table.id
# }

output "instance_type" {
  value = aws_instance.vkcorp
}

output "vpc_id" {
  value = aws_vpc.my_vpc
}

# output "instance_ip_addr" {
#   value = aws_instance.server.public_ip
# }

