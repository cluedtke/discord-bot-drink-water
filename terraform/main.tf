provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "discord_bot" {
  filename      = "discord-bot.zip"
  function_name = "discord-bot-function"
  role          = aws_iam_role.discord_bot.arn
  handler       = "bot.handler"
  runtime       = "nodejs18.x"

  source_code_hash = filebase64("discord-bot.zip")

  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_iam_role" "discord_bot" {
  name = "discord-bot-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name        = "discord-bot-schedule"
  description = "Schedule for Discord Bot"

  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "discord-bot-lambda"

  arn = aws_lambda_function.discord_bot.arn
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/lambda/${aws_lambda_function.discord_bot.function_name}"

  retention_in_days = 30
}
