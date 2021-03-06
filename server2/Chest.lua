local component = require("component")
local computer = require("computer")
local event = require("event")
local serialization = require("serialization")
local Class = require("soul/Class")

local Chest = Class:extend()

function Chest:__init(address)
	Class.__init(self)
	self.address = component.get(address)
	self.object = component.proxy(self.address)
	self.items = {}
	self.timer = nil
	self._chestTimer = function()
	  local current = {}
	  self.object.condenseItems()
	  for i=1, self.object.getInventorySize() do
	  	  local v = self.object.getStackInSlot(i)
	  	  v.slot = i
	      table.insert(current, v.all())
	  end
	  local so = serialization.serialize(self.items)
	  local sc = serialization.serialize(current)
	  if so ~= sc then
	    self.items = current
	    computer.pushSignal("chestUpdated", self.address, serialization.serialize(self.items))
	  end
	end
	self:startListener()
end

function Chest:__eq(o1, o2)
  return o1.items == o2.items
end

function Chest:startListener()
  if _G["listeners"] == nil then
  	_G["listeners"] = {}
  end  
  self.timer = event.timer(1, self._chestTimer, math.huge)
  table.insert(_G["listeners"], self.timer)
  if _G["stopListeners"] == nil then
  	_G["stopListeners"] = function()
  	  for k,v in pairs(_G["listeners"]) do
  	  	event.cancel(v)
  	  end
  	end
  end
end

function Chest:stopListener()
  event.cancel(self.timer)
end

return Chest