import { Client, GatewayIntentBits } from "discord.js";
import "dotenv/config";
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

client.on("ready", () => {
  console.log(`Logged in as ${client.user.tag}!`);
  const channel = client.channels.cache.get("1175870521213198388");
  console.log("Channel:", channel?.name);
  channel.send("Remember to drink water!");
});

client.login(process.env.DISCORD_BOT_TOKEN);
