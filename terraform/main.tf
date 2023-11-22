provider "aws" {
  region = "us-east-1"
}

locals {
  app = "discord-bot"
}

variable "discord_bot_token" {
  description = "Discord token for the bot"
  default     = "default_value"
  sensitive   = true
}
