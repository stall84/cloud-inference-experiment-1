# Default VPC/subnet keep this prototype's footprint small (no dedicated
# networking resources to create, manage, or tear down).
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# AWS publishes the latest Deep Learning Base AMI (Single CUDA, Ubuntu 24.04)
# image id as a public SSM parameter, so we never have to hardcode or
# re-discover an AMI id by hand.
data "aws_ssm_parameter" "ubuntu_dlami" {
  name = "/aws/service/deeplearning/ami/x86_64/base-with-single-cuda-ubuntu-24.04/latest/ami-id"
}
