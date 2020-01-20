variable "cidr_block" {}

variable "availability_zone" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "env" {
  default = "dev"
}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22]
}

variable "web-instance-id" {}