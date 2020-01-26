variable "cidr_block" {}

variable "availability_zone" {}

variable "env" {}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22]
}
