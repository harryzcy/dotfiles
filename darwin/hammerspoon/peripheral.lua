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
  local status = hs.execute("if mount | grep -q \"" .. path .. "\"; then echo true; else echo false; fi")
  print(13, status)
end

local path = getTMMountPoint()
if path then
  isTMMounted(path)
end
