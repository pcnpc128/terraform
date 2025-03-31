resource "aws_route_table_association" "my_route_table_assoc" {
	subnet_id	= aws_subnet.my_subnet.id
	route_table_id	= aws_route_table.my_route_table.id
}
