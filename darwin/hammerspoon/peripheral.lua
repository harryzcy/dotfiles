function getTMMountPoint()
  local mount = hs.execute("tmutil destinationinfo")
  for line in mount:gmatch("[^\r\n]+") do
    if line:match("Mount Point") then
      return line:match("Mount Point%s+:%s+(.+)")
    end
  end
  return nil
end

function isTMMounted(path)
  if path == nil then
    return false
  end  local status = hs.execute("if mount | grep -q \"" .. path .. "\"; then echo true; else echo false; fi")
  return status:match("true") ~= nil
end

function isTMRunning()
  local status = hs.execute("tmutil status")
  local data = hs.plist.readStatus(status)
  return data['Running'] == 1
end

function stopTM()
  if isTMRunning() then
    hs.execute("tmutil stopbackup")
  end
end

function unmountTM()
  local path = getTMMountPoint()
  if path == nil then
    return
  end

  stopTM()
  while isTMRunning() do
    hs.timer.usleep(100000)
  end

  hs.fs.volume.eject(path)
end

local path = getTMMountPoint()
-- unmountTM(path)
