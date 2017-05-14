local Serial = require("serialization")
local term = require("term")
local sides = require("sides")
local component = require("component")
local r = require("robot")
local Class = require("soul/Class")
local Server = require("Server")

local modem = component.modem

_DIRS = {[sides.south]={0,-1},[sides.east]={1,0},[sides.north]={0,1},[sides.west]={-1,0}}

local Robot = Class:extend()

function Robot:__init(position, facing)
  Class.__init(self)
  self.server = Server:new(modem)
  self.address, self.port = table.unpack(self.server:discover(1))
  self.facing = facing
  self.position = position
  self.tools = {}
  self.equippedItem = nil 

  for k,v in pairs(r) do
    self[k] = function(self, ...) 
      return self:_command({"robot", k}, ...) 
    end
  end
end


function Robot:_command(func, ...)
  local packet = Serial.serialize({func, {...}})  
  local response = self.server:send("CmdMsg", "CmdRsp", self.address, self.port, packet)
  local rspMsg, rspData = table.unpack(Serial.unserialize(response))
  if msg == "Done" then
    print(" Response: " .. response)
    return rspData
  end  
end


function Robot:print(text)
  self:_command({"print"}, text)
end

function Robot:_customCommand(kwargs)
  return self:_command({kwargs.func}, kwargs.args)
end

function Robot:hasComponent(component)
  local result = self:_customCommand{func="hasComponent", args=component}
  if result ~= nil then
    return result[1]
  end
  return false
end

function Robot:getInventory()
  return self:_customCommand{func="getInventory"}
end

function Robot:getPosition()
  return table.unpack(self.position)
end

function Robot:addItem(name, slot)
  self.tools[name] = slot
end

function Robot:removeItem(name)
  self.tools[name] = nil
end

function Robot:toggle_item(item)
  if self.equippedItem ~= nil then
    self:select(self.tools[self.equippedItem])
    self:_command({"component", "inventory_controller","equip"})
    self.equippedItem = nil
  end
  if item ~= nil then
    self:select(self.tools[item])
    self:_command({"component", "inventory_controller","equip"})
    self.equippedItem = item
  end
end

function Robot:goNorth()
  if self.facing == sides.south then
    self:turnAround()
  elseif self.facing == sides.east or self.facing == sides.west then
    self:turnRight()
  end
  self.facing = sides.north
  if self:forward() then
    self.position = {self.position[1]+_DIRS[self.facing][1], self.position[2], self.position[3]+_DIRS[self.facing][2]}
  end  
end

function Robot:goSouth()
  if self.facing == sides.north then
    self:turnAround()
  elseif self.facing == sides.east or self.facing == sides.west then
    self:turnLeft()
  end
  self.facing =sides.south
  if self:forward() then
    self.position = {self.position[1]+_DIRS[self.facing][1], self.position[2], self.position[3]+_DIRS[self.facing][2]}
  end  
end

function Robot:goEast()
  if self.facing == sides.west then
    self:turnAround()
  elseif self.facing == sides.north or self.facing == sides.south then
    self:turnRight()
  end
  self.facing = sides.east
  if self:forward() then
    self.position = {self.position[1]+_DIRS[self.facing][1], self.position[2], self.position[3]+_DIRS[self.facing][2]}
  end  
end

function Robot:goWest()
  if self.facing == sides.east then
    self:turnAround()
  elseif self.facing == sides.north or self.facing == sides.south then
    self:turnLeft()
  end
  self.facing = sides.west
  if self:forward() then
    self.position = {self.position[1]+_DIRS[self.facing][1], self.position[2], self.position[3]+_DIRS[self.facing][2]}
  end  
end


function Robot:go(x, z) 
  while self.position[1] ~= x and self.position[3] ~= z do
    print(Serial.serialize(self.position))
    if self.position[1] > x then
      self:goWest()
    end
    if self.position[1] < x then
      self:goEast()
    end
    if self.position[3] > z then
      self:goSouth()
    end
    if self.position[3] < z then
      self:goNorth()
    end

  end
  self.position[1] = x
  self.position[3] = z
end


return Robot