#Import EC2 Assume Role Policy Document
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
#Create IAM Role which provides permission to CloudWatch to access the EC2 instances
resource "aws_iam_role" "role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = var.aws_rolename
}
#make use of CloudWatchAgentServerPolicy (AWS Managed Policy)
data "aws_iam_policy" "impawsmanagedpolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
#Attach the CloudWatch Agent Server Policy to provide CloudWatch permission to access EC2 instances
resource "aws_iam_role_policy_attachment" "cloudwatchaccesspolicy" {
  policy_arn = data.aws_iam_policy.impawsmanagedpolicy.arn
  role       = aws_iam_role.role.name
}
