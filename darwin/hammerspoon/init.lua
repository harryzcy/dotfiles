hs.console.clearConsole()

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

function moveMouseScreen(position)
  local screens = hs.screen.allScreens()
  if #screens < 3 then
    return
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

  local rect = screen:fullFrame()
  local center = hs.geometry.rectMidPoint(rect)
  hs.mouse.absolutePosition(center)
  hs.eventtap.leftClick(center)
end

hs.hotkey.bind({'ctrl', 'shift'}, 'down', function() moveMouseScreen('bottom') end)
hs.hotkey.bind({'ctrl', 'shift'}, 'left', function() moveMouseScreen('left') end)
hs.hotkey.bind({'ctrl', 'shift'}, 'right', function() moveMouseScreen('right') end)

function moveWindowToDisplay(d)
  return function()
    local displays = hs.screen.allScreens()
    local win = hs.window.focusedWindow()
    win:moveToScreen(displays[d], false, true)
  end
end

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "1", moveWindowToDisplay(1))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "2", moveWindowToDisplay(2))

local function Chinese()
  hs.console.printStyledtext("swithcing to Chinese")
  hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC")
end

local function English()
  hs.console.printStyledtext("swithcing to English")
  hs.keycodes.currentSourceID("com.apple.keylayout.US")
end

local app2Ime = {
  {'/Applications/iTerm.app', 'English'},
  {'/System/Library/CoreServices/Finder.app', 'English'},
  {'/System/Library/CoreServices/Spotlight.app', 'English'},
  {'/Applications/System Preferences.app', 'English'},
  {'/Applications/Visual Studio Code.app', 'English'},
  {'/Applications/Wechat.app', 'Chinese'},
}

function updateFocusAppInputMethod()
  local focusAppPath = hs.window.frontmostWindow():application():path()
  for index, app in pairs(app2Ime) do
      local appPath = app[1]
      local expectedIme = app[2]

      if focusAppPath == appPath then
          if expectedIme == 'English' then
              English()
          else
              Chinese()
          end
          break
      end
  end
end

function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
      updateFocusAppInputMethod()
  end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

hs.alert.show("Config loaded")
