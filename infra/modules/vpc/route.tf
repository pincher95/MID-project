#Public Route
############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public route table"
  }
}

#Outbound route public subnet
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#Associated outbound subnet
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zone)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#Private Route
####################################################
resource "aws_route_table" "private" {
  count  = length(var.availability_zone)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private route ${element(var.availability_zone, count.index)}"
  }
}

#Outbound route private subnet
resource "aws_route" "private" {
  count                  = length(var.availability_zone)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

#Associated outbound subnet
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zone)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}