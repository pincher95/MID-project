#IP for each Availability zone
#################################
resource "aws_eip" "nat" {
  count = length(var.availability_zone)
}

#NAT gateway for each Availability zone
################################
resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zone)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  tags = {
    Name = "NAT-${element(var.availability_zone, count.index)}"
  }
}