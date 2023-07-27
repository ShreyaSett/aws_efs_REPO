terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
    profile = "default"
}

module "efs_ap" {
    source = "../module_efs"
}

#Fetch the instances created by the AutoScaling Group. Since, terraform only determines the instances once the AustoScaling group creation is completed, after initializing terraform, proceed with "terraform apply --target=module.efs_ap" to ensure creation of AutoScaling Group first. Then continue with standard "terraform apply" command to proceed with cloudwatch alarm creation.
data "aws_instances" "asginst" {
    filter {
        name = "tag:aws:autoscaling:groupName"
        values = [module.efs_ap.nameofasg]
    }
    depends_on = [module.efs_ap.aws_autoscaling_group]
}

#Create Cloudwatch custom metric alarm based on memory usage metric, one for each of the instances created by the AutoScaling Group in each availability zone.
resource "aws_cloudwatch_metric_alarm" "cwalarm" {
    for_each = toset(data.aws_instances.asginst.ids)
    alarm_name          = "alarm_${each.key}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    metric_name         = "mem_used_percent"
    namespace           = "CWAgent"
    period              = 300
    statistic           = "Average"
    threshold           = 80 #Define threshold as per requirement
    depends_on = [module.efs_ap.aws_autoscaling_group, data.aws_instances.asginst]
    insufficient_data_actions = []
    #Specify metric dimensions.
    dimensions = {
        AutoScalingGroupName = module.efs_ap.nameofasg
        InstanceId = each.value
        ImageId = module.efs_ap.ltami
        InstanceType = module.efs_ap.insttype
    }

    alarm_description = "This metric monitors ec2 Memory Utilization"
    alarm_actions     = [module.efs_ap.poliasg]
}

output "count_of_instances_createdbyasg" {
    value = length(data.aws_instances.asginst.ids)
}





