
local event = require("event")
local uuid = require("uuid")
local Class = require("soul/Class")

local function debug(s)
  require("term").write(s .. "\n", true)
end


local Server = Class:extend()

function Server:__init(modem)
  Class.__init(self)
  self.modem = modem
  self.address = self.modem.address
  self.port = math.random(65534)
end

function Server:send(msgType, rspType, address, port, msgPacket)
	local uid = uuid.new()
	self.modem.open(self.port)
	self.modem.send(address, port, msgType, uid, msgPacket, self.port)
	debug(msgType .." packet sent:"..msgPacket.."")
	local _, _, from, port, _, _rspType, _uid, rspPacket = event.pull("modem_message")
	if rspType == _rspType and uid == _uid then
		os.sleep(0.5)
		self.modem.close(self.port)
		debug(_rspType ..": "..rspPacket)
		return rspPacket
	end
end


function Server:discover(computer_type)
  local temp_port = math.random(65534)
  local uid = uuid.new()
  self.modem.open(temp_port)  
  self.modem.broadcast(12, "DscMsg", uid, computer_type, temp_port)
  debug("DscMsg sent.")
  local _, _, from, _, _, rspType, _uid, port = event.pull("modem_message")
  if rspType == "DscRsp" and uid == _uid then
    debug(rspType .." recieved.")
    self.modem.close(temp_port)
    return {from, port}
  end
  return nil  
end

return Server