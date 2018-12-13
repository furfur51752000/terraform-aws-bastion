# IAM
// Allow IAM policy to assume the role for AWS EC2
data "aws_iam_policy_document" "aws-ec2-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

// Create Role & instance profile
resource "aws_iam_role" "ec2-ssm" {
  name = "AWSEC2RoleForSSM"

  assume_role_policy = "${data.aws_iam_policy_document.aws-ec2-role-policy.json}"
}

resource "aws_iam_instance_profile" "ec2-ssm" {
  name = "AWSEC2RoleForSSM"
  role = "${aws_iam_role.ec2-ssm.name}"
}

// Attach the policy to the role
resource "aws_iam_policy_attachment" "managed-policy" {
  name       = "AmazonEC2RoleforSSM"
  roles      = ["${aws_iam_role.ec2-ssm.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

#Security Group
resource "aws_security_group" "bastion-no-ingress" {
  name        = "bastion-no-ingress"
  description = "no any inbound policy allow to bastion"
  vpc_id      = "${data.aws_vpc.cloud-hub.id}"
  tags {
    Name = "bastion_sg"
  }
}

# EC2 - spot instance
resource "aws_spot_instance_request" "bastion" {
  ami                           = "${data.aws_ami.ec2_spot_instance.id}"
  instance_type                 = "t3.nano"
  subnet_id                     = "${element(data.aws_subnet_ids.private.ids, count.index)}"
  spot_type                     = "persistent"
  iam_instance_profile          = "${aws_iam_instance_profile.ec2-ssm.name}"
  vpc_security_group_ids        = ["${aws_security_group.bastion-no-ingress.id}"]
  user_data                     = "${file("user-data.sh")}"
  wait_for_fulfillment          = "true"

  root_block_device {
      volume_size = 8
      volume_type = "gp2"
    }
  tags {
    key = "Name"
    values = "bastion"
  }
}