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

function moveWindowToScreen(win, screen)
  if not win:isFullScreen() then
    win:moveToScreen(screen, false, true)
    return
  end

  -- A native fullscreen window lives in its own Space, and Spaces belong to a
  -- display, so moveToScreen is a no-op on one. Leave fullscreen, move, re-enter.
  win:setFullScreen(false)
  hs.timer.waitWhile(function() return win:isFullScreen() end, function()
    -- the flag clears before the Space animation finishes
    hs.timer.doAfter(0.4, function()
      win:moveToScreen(screen, false, true)
      hs.timer.doAfter(0.4, function() win:setFullScreen(true) end)
    end)
  end, 0.05)
end

function moveWindowToDisplay(position)
  return function()
    local screen = getScreen(position)
    local win = hs.window.focusedWindow()
    if screen == nil or win == nil then
      return
    end

    moveWindowToScreen(win, screen)
  end
end

hs.hotkey.bind({'ctrl', 'shift'}, 'down', function() moveMouseScreen('bottom') end)
hs.hotkey.bind({'ctrl', 'shift'}, 'left', function() moveMouseScreen('left') end)
hs.hotkey.bind({'ctrl', 'shift'}, 'right', function() moveMouseScreen('right') end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "down", moveWindowToDisplay('bottom'))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "left", moveWindowToDisplay('left'))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "right", moveWindowToDisplay('right'))
