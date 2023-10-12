local function Chinese()
  hs.console.printStyledtext("swithcing to Chinese")
  if hs.keycodes.currentSourceID() ~= "com.apple.inputmethod.SCIM.ITABC" then
    hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC")
  end
end

local function English()
  hs.console.printStyledtext("swithcing to English")
  if hs.keycodes.currentSourceID() ~= "com.apple.keylayout.US" then
    hs.keycodes.currentSourceID("com.apple.keylayout.US")
  end
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
