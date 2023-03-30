resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr-block
  tags = {
    Name = "myvpc-${terraform.workspace}"
    Env = terraform.workspace
  }

}