# resource "aws_iam_role" "main" {
#   name               = local.canary_name
#   path               = "/"
#   assume_role_policy = data.aws_iam_policy_document.main_assume.json
# }

# resource "aws_iam_policy" "main"{
#   name        = "synthetics-policy-${local.canary_name}"
#   description = "Cloudwatch Synthetics Policy."
#   policy      = data.aws_iam_policy_document.canary.json
# }

# resource "aws_iam_role_policy_attachment" "main" {
#   role       = aws_iam_role.main.name
#   policy_arn = aws_iam_policy.main.arn
# }

# data "aws_iam_policy_document" "main_assume" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#   }
# }



# data "aws_iam_policy_document" "canary" {
#   depends_on = [
#     aws_s3_bucket.canary-test-bucket
#   ]
#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["arn:aws:s3:::${local.canary_bucket}/canary/${local.canary_name}/*"]
#     actions   = ["s3:PutObject"]
#   }

#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["arn:aws:s3:::${local.canary_bucket}"]
#     actions   = ["s3:GetBucketLocation"]
#   }

#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["arn:aws:sqs:us-east-1:877969058937:log-group:/aws/emergency-canary/"]

#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup",
#     ]
#   }

#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["*"]

#     actions = [
#       "s3:ListAllMyBuckets",
#       "xray:PutTraceSegments",
#     ]
#   }

#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["*"]
#     actions   = ["cloudwatch:PutMetricData"]

#     condition {
#       test     = "StringEquals"
#       variable = "cloudwatch:namespace"
#       values   = ["CloudWatchSynthetics"]
#     }
#   }

#   statement {
#     sid       = ""
#     effect    = "Allow"
#     resources = ["*"]

#     actions = [
#       "ec2:CreateNetworkInterface",
#       "ec2:DescribeNetworkInterfaces",
#       "ec2:DeleteNetworkInterface",
#     ]
#   }
# }

data "aws_iam_policy_document" "cloudwatch_policy_document" {
    
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["cloudwatch:PutMetricData"]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["CloudWatchSynthetics"]
    }
  }
}

resource "aws_iam_policy" "cloudwatch_metrics_policy"{
  name        = "synthetics-policy-${local.canary_name}"
  description = "Cloudwatch Synthetics Policy."
  policy      = data.aws_iam_policy_document.cloudwatch_policy_document.json
}

resource "aws_iam_role" "canary_role" {
  name = "synthetics-policy-${local.canary_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"

      }
    ]
  })

  inline_policy {
    name = "S3AcessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:PutObject",
            "s3:GetBucketLocation"
          ],
          Effect : "Allow"
          Resource : "arn:aws:s3:::${local.canary_bucket}/*"
        }
      ]
    })
  }
  
  inline_policy {
    name = "PolicyforTraceSegments"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
       "s3:ListAllMyBuckets",
       "xray:PutTraceSegments",
          ],
          Effect : "Allow"
          Resource : "*"
        }
      ]
    })
  }
  
  inline_policy {
    name = "CloudWatchPutMetricPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
       "cloudwatch:PutMetricData"
          ],
          Effect : "Allow"
          Resource : "*"
          Condition = {
            "StringEquals" = {
              
            }
          }
        }
      ]
    })
  }
  
  inline_policy {
    name = "EC2NetworkInterfacePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface"
          ],
          Effect : "Allow"
          Resource : "*"
        }
      ]
    })
  }
}


resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.canary_role.name
  policy_arn = aws_iam_policy.cloudwatch_metrics_policy.arn
}