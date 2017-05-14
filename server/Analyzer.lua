local component = require("component")
local event = require("event")
local serialization = require("serialization")
local Class = require("soul/Class")

local Analyzer = Class:extend()


function Analyzer:__init(address, directions)
	Class.__init(self)
	self.address = component.get(address)
	self.object = component.proxy(self.address)
	self.timer = nil
	self.isMature = {}
	for k,v in pairs(directions) do
		self.isMature[v] = false
	end	
	self.directions = directions
	self._analyzer = function()
	  current = {}
	  for k,v in pairs(directions) do
		current[v] = self.object.isMature(v)
		if current[v] ~= self.isMature[v] then
	  		self.isMature[v] = current[v]
	    	computer.pushSignal("cropMature", self.address, v, self.isMature[v])
	  	end
	  end	  
	end
	self:startListener()
end

function Analyzer:startListener()
  if _G["listeners"] == nil then
  	_G["listeners"] = {}
  end
  if _G["stopListeners"] == nil then
  	_G["stopListeners"] = function()
  	  for k,v in pairs(_G["listeners"]) do
  	  	event.cancel(v)
  	  end
  	end
  end
  self.timer = event.timer(1, self._analyzer, math.huge)
  table.insert(_G["listeners"], self.timer)
end

function Analyzer:stopListener()
  event.cancel(self.timer)
end

function Analyzer:__eq(ob1, ob2)
	return ob1.address == ob2.address
end


return Analyzer
