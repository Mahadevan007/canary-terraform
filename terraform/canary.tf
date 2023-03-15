resource "aws_s3_bucket" "canary-test-bucket" {
  bucket = "${local.canary_bucket}"

  tags = {
    Name        = "${local.canary_bucket}"
  }
}


resource "aws_synthetics_canary" "main" {
    depends_on = [
      aws_s3_bucket.canary-test-bucket
    ]
  name                 = local.canary_name
  artifact_s3_location = "s3://${local.canary_bucket}/canary/${local.canary_name}"
  execution_role_arn   = aws_iam_role.canary_role.arn
  handler              = "apiCanaryBlueprint.handler"
  start_canary         = true
  zip_file             = "/tmp/canary_zip_inline.zip"
  runtime_version      = "syn-nodejs-puppeteer-3.9"
  
  # VPC Config
  # vpc_config {
  #   subnet_ids         = 
  #   security_group_ids = 
  # }

    run_config {
    active_tracing = true
    timeout_in_seconds = 60
  }

  schedule {
    expression = "rate(5 minutes)"
  }

}

data "archive_file" "canary_zip_inline" {
    depends_on = [
      aws_s3_bucket.canary-test-bucket
    ]
  type        = "zip"
  output_path = "/tmp/canary_zip_inline.zip"
  
  source {
    content  = templatefile("${path.module}/../templates/canary_node.tmpl", {
      endpoint = var.endpoint
      hostname = var.endpoint
      endpointpath = var.endpointpath
      port = var.port
    })
    filename = "nodejs/node_modules/apiCanaryBlueprint.js"
  }
}