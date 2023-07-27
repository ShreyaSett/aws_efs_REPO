#Create instance profile from the iam role to allow CloudWatch agent access to the instances to be created by AutoScaling Group Launch Template.
resource "aws_iam_instance_profile" "test_profile" {
  role = aws_iam_role.role.name
}

#Create AutoScaling Group Launch Template.
resource "aws_launch_template" "launchtemp" {
    name = var.aws_launchtemp
    depends_on = [aws_iam_instance_profile.test_profile]
    iam_instance_profile {
      arn = aws_iam_instance_profile.test_profile.arn
    }
    image_id = var.aws_ami
    instance_type = var.aws_instancetype
    key_name = var.aws_kp
    monitoring {
      enabled = true
    }
    vpc_security_group_ids = var.aws_ltsgs
    user_data = filebase64("../udt.sh") #udt.sh contains the user data to be passed on in the Launch Template.
}

#Create AutoScaling Group.  
resource "aws_autoscaling_group" "tasg" {
  name                      = var.aws_asgname
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  depends_on                = [aws_launch_template.launchtemp, aws_lb_target_group.tgtgrp]
  launch_template {
    id      = aws_launch_template.launchtemp.id
    version = "$Latest"
  }
  vpc_zone_identifier       = var.aws_privsubnets
  target_group_arns         = ["${aws_lb_target_group.tgtgrp.arn}"]

}

#Create Application Load Balancer.
resource "aws_lb" "tlb" {
  name               = var.aws_albname
  subnets            = var.aws_pubsubnets
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.aws_lbsgs
}

#Create Application Load Balancer Target Group.
resource "aws_lb_target_group" "tgtgrp" {
  name        = var.aws_tgtname
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.aws_vpcid
  target_type = "instance"

  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    protocol            = "HTTP"
    matcher             = "200,403"
  }
}

#Create Application Load Balancer Listener.
resource "aws_lb_listener" "alblistener" {
  load_balancer_arn = "${aws_lb.tlb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.tgtgrp.arn}"
    type             = "forward"
  }
}

#Create Scaling Policy(Step Scaling) for the AutoScaling Group created.
resource "aws_autoscaling_policy" "asgpol" {
  name                   = var.aws_asgpolname
  adjustment_type        = "ChangeInCapacity"
  policy_type = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.tasg.name
  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 2.0
    metric_interval_upper_bound = null
  }
}
output "nameofasg" {
  value = aws_autoscaling_group.tasg.name
}
output "poliasg" {
  value = aws_autoscaling_policy.asgpol.arn
}
output "ltami" {
  value = aws_launch_template.launchtemp.image_id
}
output "insttype" {
  value = aws_launch_template.launchtemp.instance_type
}
