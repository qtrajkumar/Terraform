region = "us-west-2"
aws_subnet_info = {
  subnet_azs      = ["a", "b", "a", "b"]
  subnet_names    = ["app1", "app2", "db1", "db2"]
  vpc_cidr        = "10.100.0.0/16"
  public_subnets  = ["web1", "web2"]
  private_subnets = ["app1", "app2", "db1", "db2"]
  db_subnets      = ["db1", "db2"]
}