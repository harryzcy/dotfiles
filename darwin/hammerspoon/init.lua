hs.console.clearConsole()

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

function moveMouseScreen(screenNum)
  local screens = hs.screen.allScreens()
  if #screens < screenNum then
    return
  end

  local rect = screens[screenNum]:fullFrame()
  local center = hs.geometry.rectMidPoint(rect)
  hs.mouse.absolutePosition(center)
  hs.eventtap.leftClick(center)
end
hs.hotkey.bind({'cmd', 'shift'}, 'left', function() moveMouseScreen(1) end)
hs.hotkey.bind({'cmd', 'shift'}, 'right', function() moveMouseScreen(2) end)

function moveWindowToDisplay(d)
  return function()
    local displays = hs.screen.allScreens()
    local win = hs.window.focusedWindow()
    win:moveToScreen(displays[d], false, true)
  end
end

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "1", moveWindowToDisplay(1))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "2", moveWindowToDisplay(2))

hs.alert.show("Config loaded")
