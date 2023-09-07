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
hs.hotkey.bind({'cmd', 'shift'}, 'down', function() moveMouseScreen(1) end)
hs.hotkey.bind({'cmd', 'shift'}, 'left', function() moveMouseScreen(2) end)
hs.hotkey.bind({'cmd', 'shift'}, 'right', function() moveMouseScreen(3) end)

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
