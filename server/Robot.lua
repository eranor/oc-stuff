local serialization = require("serialization")
local Class = require("soul/Class")
local term = require("term")
local sides = require("sides")
local component = require("component")
local modem = component.modem

local Robot = Class:extend()
function Robot:__init(address, port, position, facing)
	Class.__init(self)
	self.address = address
	self.port = port
	self.facing = facing
	self.position = position
end

_DIRS = {{0,-1},{1,0},{0,1},{-1,0}}

function Robot:_command(func, ...)
	local message = serialization.serialize({func, {...}})
	modem.send(self.address, self.port, "CommandMessage", message)
	local _func = tostring(serialization.serialize(func))
	local _arg = tostring(serialization.serialize(...))
	term.write("Command{".._func.."(".._arg..")} sent :")
	local _, _, from, port, _, responseType, message, args = event.pull("modem_message")
	if responseType == "CommandResponse" then
		if message == "Done" then
			os.sleep(0.5)
			term.write("\n  Response: " .. args .. "\n")
			return serialization.unserialize(args)
		end
	end	
end

function Robot:print(text)
	self:_command({"print"}, text)
end

function Robot:select(slot)
	return self._command({"robot", "select"}, slot)
end

function Robot:getInventory()
	local message = serialization.serialize({"getInventory"})
	modem.send(self.address, self.port, "CommandMessage", message)
	term.write("Command{getInventory()} sent :")
	local _, _, from, port, _, responseType, message, args = event.pull("modem_message")
	if responseType == "CommandResponse" then
		if message == "Done" then
			os.sleep(0.5)
			term.write("\n  Response: " .. args .. "\n")
			return serialization.unserialize(args)
		end
	end	
end

function Robot:_move(command_name, times)
	local result = {}
	for i=1,times or 1 do
		if command_name == "turnLeft" or command_name == "turnRight" then
			self.facing = (self.facing - 1) % 4	
		elseif command_name == "turnAround"  then
			self.facing = (self.facing + 2) % 4
		elseif command_name == "forward" or command_name == "back" then
			self.position = {self.position[1] + _DIRS[self.facing][0], self.position[2], self.position[3] + _DIRS[self.facing][2]}
		elseif command_name == "up" then
			self.position[2] = self.position[2] + 1
		elseif command_name == "down" then
			self.position[2] = self.position[2] - 1
		end
		table.insert(result, self:_command({"robot",command_name}))
	end
	return result
end

function Robot:turnLeft(times)
	return self:_move("turnLeft",times)
end

function Robot:turnRight(times)
	return self:_move("turnRight",times)
end

function Robot:turnAround(times)
	return self:_move("turnAround",times)
end

function Robot:forward(times)
	return self:_move("forward",times)
end

function Robot:back(times)
	return self:_move("back",times)
end

function Robot:up(times)
	return self:_move("up",times)
end

function Robot:down(times)
	return self:_move("down",times)
end

return Robot