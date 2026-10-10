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

-- seconds to wait for a Space transition before giving up
local spaceTransitionTimeout = 3

-- Runs action once predicate holds; gives up silently after the timeout.
local function waitUntil(predicate, action)
  local deadline = hs.timer.secondsSinceEpoch() + spaceTransitionTimeout
  local timer
  timer = hs.timer.doEvery(0.05, function()
    if predicate() then
      timer:stop()
      action()
    elseif hs.timer.secondsSinceEpoch() > deadline then
      timer:stop()
    end
  end)
end

local function showsUserSpace(screen)
  local space = hs.spaces.activeSpaceOnScreen(screen)
  return space ~= nil and hs.spaces.spaceType(space) == 'user'
end

-- IDs of win's sibling windows on screen, e.g. Chrome's fullscreen overlays.
local function companionWindowIDs(win, screen)
  local pid = win:application():pid()
  local frame = screen:fullFrame()
  local ids = {}
  for _, info in ipairs(hs.window.list(false)) do
    local b = info.kCGWindowBounds
    if info.kCGWindowOwnerPID == pid and info.kCGWindowLayer == 0
        and info.kCGWindowNumber ~= win:id()
        and hs.geometry.rect(b.X, b.Y, b.Width, b.Height):intersect(frame).area > 0 then
      ids[info.kCGWindowNumber] = true
    end
  end
  return ids
end

local function anyStillOnScreen(ids, win, screen)
  for id in pairs(companionWindowIDs(win, screen)) do
    if ids[id] then
      return true
    end
  end
  return false
end

-- Entering fullscreen right after a move sometimes doesn't take, so check
local fullscreenRetryInterval = 0.5
local fullscreenAttempts = 6

local function enterFullScreen(win, attempts)
  win:setFullScreen(true)
  hs.timer.doAfter(fullscreenRetryInterval, function()
    if win:isFullScreen() then
      return
    end
    if attempts > 1 then
      hs.console.printStyledtext("fullscreen didn't take, retrying (" .. (attempts - 1) .. " left)")
      enterFullScreen(win, attempts - 1)
    else
      hs.console.printStyledtext("fullscreen didn't take, giving up")
    end
  end)
end

function moveWindowToScreen(win, screen)
  if not win:isFullScreen() then
    win:moveToScreen(screen, false, true)
    return
  end

  -- A native fullscreen window lives in its own Space, and Spaces belong to a
  -- display, so moveToScreen is a no-op on one. Leave fullscreen, move, re-enter.
  -- Moving mid-transition leaves the app's fullscreen overlays frozen on the
  -- old display, so wait for them to go away first.
  local fromScreen = win:screen()
  local overlays = companionWindowIDs(win, fromScreen)
  win:setFullScreen(false)
  waitUntil(function()
    return not win:isFullScreen() and showsUserSpace(fromScreen)
      and not anyStillOnScreen(overlays, win, fromScreen)
  end, function()
    win:moveToScreen(screen, false, true, 0)
    waitUntil(function()
      return win:screen():id() == screen:id()
    end, function() enterFullScreen(win, fullscreenAttempts) end)
  end)
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
