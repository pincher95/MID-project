variable "web-instance-id" {}
variable "vpc_id" {}
variable "public_subnet" {
  type = list(string)
}
variable "env" {}