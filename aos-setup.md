
Hacker Bot Deathmatch 2024
EthDenver
At this point you should have your bot on aos ready to go. If not you can try to build a bot and register before 3pm:

https://cookbook_ao.arweave.dev/tutorials/bots-and-games/index.html (Good Luck)
https://cookbook_ao.arweave.dev/guides/aos/intro.html (introduction to Decentralized AOS terminal Operating System)
https://cookbook_ao.arweave.dev/tutorials/bots-and-games/ao-effect.html (DEFI Bot Games)

in aos and execute the following commands

-- load your bot if not already loaded
.load bot.lua
Game = "Fy84wf3FeHBgOdXsPrNIdqVvkrspGJpRUOd4QFu2044"
Send({ Target = Game, Action = "RequestTokens", Data = "deathmatch"})
Send({ Target = Game, Action = "Register"})
You are ready for the event, the game will start at 3pm!

Tips
Sometime your bot can stall, if it has not moved for a bit, you can give it a nudge by doing the following:

InAction = false
Send({Target = ao.id, Action = "Tick"})
Good Luck!!!