variable "aws_rolename" {
    description = "Assume Role name for EC2 providing access to CloudWatch"
    type = string
}

variable "aws_launchtemp" {
    description = "Launch Template name for the ASG"
    type = string
}

variable "aws_kp" {
    description = "Key Pair to be used for instance login"
    type = string
}

variable "aws_ami" {
    description = "AMI ID to be used"
    type = string
}

variable "aws_ltsgs" {
    description = "Security Groups to be associated in the Launch Template" #Since, we want the instances to be running in a private subnet, make sure the Security Groups are not open to the internet.
    type = list
}

variable "aws_instancetype" {
    description = "Instance Type to be specified in the Launch Template"
    type = string
}

variable "aws_asgname" {
    description = "AutoScaling Group Name"
    type = string
}

variable "aws_asgpolname" {
    description = "AutoScaling Group Policy Name"
    type = string
}

variable "aws_pubsubnets" {
    description = "Subnets to be used by the internet-facing Application Load Balancer"
    type = list
}

variable "aws_privsubnets" {
    description = "Private Subnets to be used by the AutoScaling Group to launch the instances"
    type = list
}

variable "aws_lbsgs" {
    description = "Security Groups to be associated with the Load Balancer" #The Application Load Balancer is internet facing. Hence, make sure the Security Groups allow traffic from and to the internet.
    type = list
}

variable "aws_albname" {
    description = "Application Load Balancer Name"
    type = string
}

variable "aws_tgtname" {
    description = "Target Group Name associated with the Application Load Balancer"
    type = string
}

variable "aws_vpcid" {
    description = "VPC ID"
    type = string
}


