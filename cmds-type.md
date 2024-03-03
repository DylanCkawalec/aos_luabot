#### Commands used in the aos Hacker deathmatch for Arweave, aos Terminal Hack.
------------------------------------------------------------------------------ */
#### Get you ID : examples : 
NPhS-bQID2osEPFZM3AYZ9vc4Fdr9za4ByVB_DLyCRg
> Game = "Fy84wf3FeHBgOdXsPrNIdqVvkrspGJpRUOd4QFu2044"

#### Test Functional Connection: 
$ ```Send({ Target = Game, Action = "PlayerAttack", Player = ao.id, AttackEnergy = "energy_integer"})```
$ ```Send({Target = ao.id, Action = "Tick"})```
$ ```Send({Target = ao.id, Action = "Tick"})Send({Target = ao.id, Action = "Tick"})```
$ ```Send({ Target = Game, Action = "RequestTokens", Data = "deathmatch"})Send({ Target = Game, Action = "RequestTokens", Data = "deathmatch"})```

### After aos server connection and admin registeration, load in your bot cmd:
$ . load ./Desktop/mybot/bot.lua

### To fetch the state of the game: 
$ LatestGameState

### To know your Move set:
$ Handlers.list


### Test fully connection in game: 
$ InAction = false

## To check your gamer ID:
$ ao.id
 



# instalation in any terminal : 
npm i -g https://get_ao.g8way.io


# Launch aos Next, create your instance of aos:
aos

# example registration for server some ID: 
Game = "3HSmhQ-lHaCQlOKtq5GDgbVQXQ6mWIp40uUASAG13Xk"

"And voilà! You're all set to join the game."

Then build a bot mybot.lua 

https://cookbook_ao.arweave.dev/references/lua.html
