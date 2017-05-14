local component = require("component")
local event = require("event")
local serialization = require("serialization")
local Class = require("soul/Class")

local Item = Class:extend()

function Item:__init(item_table)
	Class.__init(self)
	for k,v in pairs(item_table) do
		self[k] = v
	end
end

function Item:getCount()
	return self.qty
end

function Item:getName(raw)
	return raw and self.raw_name or self.display_Name
end

function Item:getHash()
	return nbt_hash
end

function Item:__eq(o1, o2)
	if o1.raw_name == o2.raw_name and o1.id == o2.id and
		o1.dmg == o2.dmg and o1.qty == o2.qty then
		if o1.nbt_hash and o2.nbt_hash then
			return o1.nbt_hash == o2.nbt_hash
		elseif o1.nbt_hash or o2.nbt_hash then
			return false
		else
			return true	
		end
	end
	return false
end

return Item
