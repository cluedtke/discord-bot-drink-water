# Lambda CI
resource "null_resource" "ci_build" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = join(" && ", [
      "rm -rf ${path.module}/../ci",
      "mkdir ${path.module}/../ci",
      "cp ${path.module}/../lambda.mjs ${path.module}/../node_modules -r ${path.module}/../ci/",
    ])
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../ci"
  output_path = "lambda.zip"
  depends_on  = [null_resource.ci_build]
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.bucket.id
  key    = "lambda.zip"
  source = data.archive_file.lambda_zip.output_path

  # etag = filemd5(data.archive_file.lambda_zip.output_path)

  depends_on = [data.archive_file.lambda_zip]
  # tags = merge(local.common_tags, {
  #   build = var.build_number
  # })
}

# Lambda Resource
resource "aws_lambda_function" "lambda" {
  function_name = "discord-bot-function"

  s3_bucket = aws_s3_bucket.bucket.id
  s3_key    = aws_s3_object.lambda_zip.key
  runtime   = "nodejs18.x"
  handler   = "lambda.handler"
  timeout   = 10

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.discord_bot_role.arn

  environment {
    variables = {
      DISCORD_BOT_TOKEN = var.discord_bot_token
    }
  }

  tracing_config {
    mode = "PassThrough"
  }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"

  retention_in_days = 30
}

# Lambda Trigger
resource "aws_cloudwatch_event_rule" "cron_schedule" {
  name        = "${local.app}-schedule"
  description = "Schedule for Discord Bot"

  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "cron_target" {
  rule      = aws_cloudwatch_event_rule.cron_schedule.name
  target_id = "${local.app}-lambda"

  arn = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_schedule.arn
}
