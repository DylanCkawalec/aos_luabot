-- Constants
local ENERGY_THRESHOLD = 5
local ATTACK_RANGE = 1

-- Initializing global variables to store the latest game state and game host process.
LatestGameState = LatestGameState or nil
InAction = InAction or false -- Prevents the agent from taking multiple actions at once.

Logs = Logs or {}

colors = {
  red = "\27[31m",
  green = "\27[32m",
  blue = "\27[34m",
  reset = "\27[0m",
  gray = "\27[90m"
}

function addLog(msg, text) -- Function definition commented for performance, can be used for debugging
  Logs[msg] = Logs[msg] or {}
  table.insert(Logs[msg], text)
end

-- Checks if two points are within a given range.
-- @param x1, y1: Coordinates of the first point.
-- @param x2, y2: Coordinates of the second point.
-- @param range: The maximum allowed distance between the points.
-- @return: Boolean indicating if the points are within the specified range.
function inRange(x1, y1, x2, y2, range)
    return math.abs(x1 - x2) <= range and math.abs(y1 - y2) <= range
end

-- Avoid recursive calls
function attackLowestEnergyPlayer()
  local player = latestGameState.Players[ao.id]
  local target = getLowestEnergyPlayerInRange(player.x, player.y, ATTACK_RANGE)

  while player.energy > ENERGY_THRESHOLD and target do
    print(colors.red .. "Player in range. Attacking." .. colors.reset)
    ao.send({Target = Game, Action = "PlayerAttack", Player = ao.id, AttackEnergy = tostring(player.energy)})
    target = getLowestEnergyPlayerInRange(player.x, player.y, ATTACK_RANGE)
  end
end

-- Avoid code duplication
function getLowestEnergyPlayerInRange(x, y, range)
  local minEnergy = math.huge
  local targetInRange = nil

  for target, state in pairs(latestGameState.Players) do
      if target ~= ao.id and inRange(x, y, state.x, state.y, range) and state.energy < minEnergy then
          minEnergy = state.energy
          targetInRange = target
      end
  end

  return targetInRange
end

-- Rest to regain energy when it's low.
function restAndRegainEnergy()
  local player = latestGameState.Players[ao.id]
  if player and player.energy < ENERGY_THRESHOLD then
    print(colors.red .. "Energy is low. Resting to regain energy." .. colors.reset)
    ao.send({Target = Game, Action = "PlayerRest", Player = ao.id})
    inAction = false
  end
end

-- Recursive attack: Attack the player with the lowest energy within range multiple times.
function recursiveAttack()
  local player = LatestGameState.Players[ao.id]
  local minEnergy = math.huge
  local targetInRange = nil

  for target, state in pairs(LatestGameState.Players) do
      if target ~= ao.id and inRange(player.x, player.y, state.x, state.y, 1) and state.energy < minEnergy then
          minEnergy = state.energy
          targetInRange = target
      end
  end

  if player.energy > 5 and targetInRange then
    print(colors.red .. "Player in range. Attacking." .. colors.reset)
    ao.send({Target = Game, Action = "PlayerAttack", Player = ao.id, AttackEnergy = tostring(player.energy)})
    -- Recursive call
    recursiveAttack()
  end
end

-- Decides the next action based on player proximity and energy.
-- If any player is within range, it initiates an attack; otherwise, moves randomly.
-- Improved decision making: Attack the player with the lowest energy within range.
function decideNextAction()
  local player = LatestGameState.Players[ao.id]
  local minEnergy = math.huge
  local targetInRange = nil

  for target, state in pairs(LatestGameState.Players) do
      if target ~= ao.id and inRange(player.x, player.y, state.x, state.y, 1) and state.energy < minEnergy then
          minEnergy = state.energy
          targetInRange = target
      end
  end

  if player.energy > 5 and targetInRange then
    recursiveAttack()
    print(colors.red .. "Player in range. Attacking." .. colors.reset)
    ao.send({Target = Game, Action = "PlayerAttack", Player = ao.id, AttackEnergy = tostring(player.energy)})
  elseif player.energy > 0 then
    print(colors.red .. "No player in range or insufficient energy. Moving towards energy source." .. colors.reset)
    -- Assuming there's a function getDirectionToEnergySource() that returns the direction to the nearest energy source.
    local directionToEnergySource = getDirectionToEnergySource(player.x, player.y)
    ao.send({Target = Game, Action = "PlayerMove", Player = ao.id, Direction = directionToEnergySource})
  end
  InAction = false
end

-- Handler to print game announcements and trigger game state updates.
Handlers.add(
  "PrintAnnouncements",
  Handlers.utils.hasMatchingTag("Action", "Announcement"),
  function (msg)
    if msg.Event == "Started-Waiting-Period" then
      ao.send({Target = ao.id, Action = "AutoPay"})
    elseif (msg.Event == "Tick" or msg.Event == "Started-Game") and not InAction then
      InAction = true -- InAction logic added
      ao.send({Target = Game, Action = "GetGameState"})
    elseif InAction then -- InAction logic added
      print("Previous action still in progress. Skipping.")
    end
    print(colors.green .. msg.Event .. ": " .. msg.Data .. colors.reset)
  end
)

-- Handler to trigger game state updates.
Handlers.add(
  "GetGameStateOnTick",
  Handlers.utils.hasMatchingTag("Action", "Tick"),
  function ()
    if not InAction then -- InAction logic added
      InAction = true -- InAction logic added
      print(colors.gray .. "Getting game state..." .. colors.reset)
      ao.send({Target = Game, Action = "GetGameState"})
    else
      print("Previous action still in progress. Skipping.")
    end
  end
)

-- Handler to automate payment confirmation when waiting period starts.
Handlers.add(
  "AutoPay",
  Handlers.utils.hasMatchingTag("Action", "AutoPay"),
  function (msg)
    print("Auto-paying confirmation fees.")
    ao.send({ Target = Game, Action = "Transfer", Recipient = Game, Quantity = "1000"})
  end
)

-- Handler to update the game state upon receiving game state information.
Handlers.add(
  "UpdateGameState",
  Handlers.utils.hasMatchingTag("Action", "GameState"),
  function (msg)
    local json = require("json")
    LatestGameState = json.decode(msg.Data)
    ao.send({Target = ao.id, Action = "UpdatedGameState"})
    print("Game state updated. Print \'LatestGameState\' for detailed view.")
  end
)

-- Handler to decide the next best action.
Handlers.add(
  "decideNextAction",
  Handlers.utils.hasMatchingTag("Action", "UpdatedGameState"),
  function ()
    if LatestGameState.GameMode ~= "Playing" then
      InAction = false -- InAction logic added
      return
    end
    print("Deciding next action.")
    decideNextAction()
    ao.send({Target = ao.id, Action = "Tick"})
  end
)

-- Improved ReturnAttack handler: Only attack if the player has enough energy and the attacker is within range.
Handlers.add(
  "ReturnAttack",
  Handlers.utils.hasMatchingTag("Action", "Hit"),
  function (msg)
    if not InAction then
      InAction = true
      local playerEnergy = LatestGameState.Players[ao.id].energy
      local attackerInRange = inRange(LatestGameState.Players[ao.id].x, LatestGameState.Players[ao.id].y, LatestGameState.Players[msg.Attacker].x, LatestGameState.Players[msg.Attacker].y, 1)
      if playerEnergy == undefined then
        print(colors.red .. "Unable to read energy." .. colors.reset)
        ao.send({Target = Game, Action = "Attack-Failed", Reason = "Unable to read energy."})
      elseif playerEnergy == 0 or not attackerInRange then
        print(colors.red .. "Player has insufficient energy or attacker is out of range." .. colors.reset)
        ao.send({Target = Game, Action = "Attack-Failed", Reason = "Player has no energy or attacker is out of range."})
      else
        print(colors.red .. "Returning attack." .. colors.reset)
        ao.send({Target = Game, Action = "PlayerAttack", Player = ao.id, AttackEnergy = tostring(playerEnergy)})
      end
      InAction = false
      ao.send({Target = ao.id, Action = "Tick"})
    else
      print("Previous action still in progress. Skipping.")
    end
  end
)