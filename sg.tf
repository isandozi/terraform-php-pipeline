resource "aws_security_group" "modetrans_bastion_sg" {
  name        = "${var.application_name}-${var.application_environment[var.region]}-Bastion-SG"
  vpc_id      = aws_vpc.modetrans_vpc.id
  description = "Security Group for Modetrans Bastion Host"

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-Bastion-SG"
  }
}

resource "aws_security_group_rule" "modetrans_bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.modetrans_bastion_sg.id
  description       = "Allows all traffic to Internet"
}
/*
The following rule is not recommended since this ingress rule opens up SSH access to the entire environment.
This is only here for the purpose of this exercise.
*/
resource "aws_security_group_rule" "bastion_ingress_ssh_anywhere" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.modetrans_bastion_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allows SSH from anywhere"
}

resource "aws_security_group" "modetrans_instance_sg" {
  name        = "${var.application_name}-${var.application_environment[var.region]}-Instance-SG"
  vpc_id      = aws_vpc.modetrans_vpc.id
  description = "Security Group for Modetrans Instances"

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-Instance-SG"
  }
}

resource "aws_security_group_rule" "modetrans_instance_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.modetrans_instance_sg.id
  description       = "Allows all traffic to Internet"
}

resource "aws_security_group_rule" "modetrans_ingress_from_bastion" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.modetrans_instance_sg.id
  source_security_group_id = aws_security_group.modetrans_bastion_sg.id
  description              = "Allows all traffic from Modetrans Bastion Host"
}

resource "aws_security_group_rule" "modetrans_ingress_from_lb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.modetrans_instance_sg.id
  source_security_group_id = aws_security_group.modetrans_alb_sg.id
  description              = "Allows all traffic from Load Balancer"
}

resource "aws_security_group" "modetrans_alb_sg" {
  name        = "${var.application_name}-${var.application_environment[var.region]}-LB-SG"
  vpc_id      = aws_vpc.modetrans_vpc.id
  description = "Security Group for Modetrans Load Balancer"

  tags = {
    Name = "${var.application_name}-${var.application_environment[var.region]}-LB-SG"
  }
}

resource "aws_security_group_rule" "modetrans_lb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.modetrans_alb_sg.id
  description       = "Allows all traffic to Internet"
}

resource "aws_security_group_rule" "modetrans_lb_ingress_http_from_internet" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.modetrans_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allows HTTP from Internet"
}

output "Modetrans_Bastion_SG_ID" {
  value = aws_security_group.modetrans_bastion_sg.id
}

output "Modetrans_Instance_SG_ID" {
  value = aws_security_group.modetrans_instance_sg.id
}

output "Modetrans_LB_SG_ID" {
  value = aws_security_group.modetrans_alb_sg.id
}
