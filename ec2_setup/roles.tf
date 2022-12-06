resource  "aws_iam_role" "ECR_to_EC2" {
  name               = "ECR_to_EC2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ECRPuller" {
  name        = "ECRPuller"
  path        = "/"
  description = "Policy to provide permissions to EC2"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:PutLifecyclePolicy",
                "ecr:PutImageTagMutability",
                "ecr:StartImageScan",
                "ecr:CreateRepository",
                "ecr:PutImageScanningConfiguration",
                "ecr:UploadLayerPart",
                "ecr:BatchDeleteImage",
                "ecr:DeleteLifecyclePolicy",
                "ecr:DeleteRepository",
                "ecr:PutImage",
                "ecr:CompleteLayerUpload",
                "ecr:StartLifecyclePolicyPreview",
                "ecr:InitiateLayerUpload",
                "ecr:DeleteRepositoryPolicy",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer"
            ],
            "Resource": "arn:aws:ecr:eu-central-1:837222496434:repository/jenkins_repo"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:BatchCheckLayerAvailability",
            "Resource": "arn:aws:ecr:eu-central-1:837222496434:repository/jenkins_repo"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "ECRPuller_to_EC2" {
  policy_arn = aws_iam_policy.ECRPuller.arn
  role       = aws_iam_role.ECR_to_EC2.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ECR_to_EC2.name
}