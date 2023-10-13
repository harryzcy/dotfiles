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
  end
  local status = hs.execute("if mount | grep -q \"" .. path .. "\"; then echo true; else echo false; fi")
  return status:match("true") ~= nil
end

local path = getTMMountPoint()
isTMMounted(path)
