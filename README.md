# discord-bot-drink-water

A discord bot that reminds me to drink water. CI/CD enabled via Concourse CI.

## Credentails File

```sh
echo discord_bot_token: {{placeholder}} > credentials.yml
echo github_apikey: {{placeholder}} >> credentials.yml
echo aws_access_key_id: {{placeholder}} >> credentials.yml
echo aws_secret_access_key: {{placeholder}} >> credentials.yml
```

## Concourse CI/CD

```sh
# 1 Run docker-compose
docker-compose up

# 2 Log into Concourse
fly login -t tutorial --concourse-url http://localhost:8080/

# 3 Set the Pipeline
fly -t tutorial set-pipeline -p discord-bot -c pipeline.yml -l credentials.yml

# 4 Unpause the Pipeline
fly -t tutorial unpause-pipeline -p discord-bot

# 5 Trigger Pipeline Job
fly -t tutorial trigger-job --job discord-bot/deploy-bot --watch
```
