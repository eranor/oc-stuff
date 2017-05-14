local component = require("component")
local event = require("event")
local serialization = require("serialization")
local Class = require("soul/Class")
local coroutine = require("coroutine")
local modem = component.modem

local Hearthbeat = Class:extend()

function Hearthbeat:__init(address, port)
	Class.__init(self)
	self.address = address
	self.port = port
	self.running = false
end

function run()
	while self.running do
		modem.send(self.address, self.port, "hearthbeat")
		local event, _, from, port, _, responseType, message, args = event.pull(1.5,"modem_message")
		if event == nil and responseType == "HearthbeatResponse" then
			self.running = false
			break
		end
		print("beat")
		os.sleep(8.5)
	end
end

function Hearthbeat:start()
	self.running = true
	self.coro = coroutine.create(run)
	coroutine.resume(self.coro)
end

return Hearthbeat