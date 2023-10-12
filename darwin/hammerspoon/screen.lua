function getScreen(position)
  local screens = hs.screen.allScreens()
  if #screens < 3 then
    return nil
  end

  local bottomScreen = screens[1]
  local topLeftScreen
  local topRightScreen

  x2, y2 = screens[2]:position()
  x3, y3 = screens[3]:position()
  if x2 > x3 then
    topLeftScreen = screens[3]
    topRightScreen = screens[2]
  else
    topLeftScreen = screens[2]
    topRightScreen = screens[3]
  end

  local screen
  if position == 'bottom' then
    screen = bottomScreen
  elseif position == 'left' then
    screen = topLeftScreen
  elseif position == 'right' then
    screen = topRightScreen
  else
    return
  end

  return screen
end

function moveMouseScreen(position)
  local screen = getScreen(position)
  if screen == nil then
    return
  end

  local rect = screen:fullFrame()
  local center = hs.geometry.rectMidPoint(rect)
  hs.mouse.absolutePosition(center)
  hs.eventtap.leftClick(center)
end

function moveWindowToDisplay(position)
  return function()
    local screen = getScreen(position)
    local win = hs.window.focusedWindow()
    win:moveToScreen(screen, false, true)
  end
end

hs.hotkey.bind({'ctrl', 'shift'}, 'down', function() moveMouseScreen('bottom') end)
hs.hotkey.bind({'ctrl', 'shift'}, 'left', function() moveMouseScreen('left') end)
hs.hotkey.bind({'ctrl', 'shift'}, 'right', function() moveMouseScreen('right') end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "down", moveWindowToDisplay('bottom'))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "left", moveWindowToDisplay('left'))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "right", moveWindowToDisplay('right'))
