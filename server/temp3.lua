local scheduler = require "loop.thread.Scheduler"

function control(room)
  local c = 0
  while true do
    if room.light and not room.presence then
      c = c + 1
      if c > 5 then
        c = 0
        room.light = false
      else
        scheduler:suspend(1)
      end
    else
      c = 0
      scheduler:suspend(6)
    end
  end
end

function person(rooms)
  local room = 0
  while true do
    room = 1 + (room + math.random(#rooms-1)) % #rooms
    rooms[room].presence = true
    rooms[room].light = true
    scheduler:suspend(math.random(6))
    rooms[room].presence = false
  end
end

function printer(rooms)
  while true do
    for _, room in ipairs(rooms) do
      io.write("  ", room.presence and "*" or room.light and "." or  " ")
    end
    print()
    scheduler:suspend(1)
  end
end

scheduler:register(coroutine.create(function()
  local rooms = {}
  for i = 1, 9 do rooms[i] = {} end
  
  scheduler:start(printer, rooms)
  scheduler:start(person, rooms)
  scheduler:suspend(60)
  
  print "starting light control ..."
  for _, room in ipairs(rooms) do
    scheduler:start(control, room)
  end
end))

scheduler:run()