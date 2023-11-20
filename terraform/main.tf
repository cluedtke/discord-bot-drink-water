provider "aws" {
  region  = "us-east-1"
}

resource "aws_lambda_function" "discord_bot" {
  filename      = "discord-bot.zip"
  function_name = "discord-bot-function"
  role          = aws_iam_role.discord_bot.arn
  handler       = "bot.handler"
  runtime       = "nodejs18.x"

  source_code_hash = filebase64("../discord-bot.zip")
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
