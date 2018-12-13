// variable for main.auto.tf
variable "profile" {
  description = "aws login profile"
  default     = ""
}

variable "assume_role" {
  description = "aws login assueme role"
  default     = ""
}

variable "region" {
  description = "aws region"
  default     = ""
}

# Search the latest AMI to launch EC2 instance
data "aws_ami" "ec2_spot_instance" {
    most_recent = true

    filter {
      name  = "name"
      values    = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"]
    }

    filter {
        name    = "virtualization-type"
        values  = ["hvm"]
    }

    owners  = ["099720109477"] # Canonical

}

# Search the vpc id
data "aws_vpc" "cloud-hub" {

    filter {
        name    = "tag:Name"
        values  = ["VPC-hub-shared-*"]
    }
}

# Search the private subnet id
data "aws_subnet_ids" "private" {
  
    vpc_id = "${data.aws_vpc.cloud-hub.id}"

    filter {
        name    = "tag:Name"
        values  = ["SN-private*"]
    }
}