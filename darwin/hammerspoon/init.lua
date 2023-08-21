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

local function Chinese()
  hs.console.printStyledtext("swithcing to Chinese")
  hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC")
end

local function English()
  hs.console.printStyledtext("swithcing to English")
  hs.keycodes.currentSourceID("com.apple.keylayout.US")
end

local function set_app_input_method(app_name, set_input_method_function, event)
  event = event or hs.window.filter.windowFocused
  hs.window.filter.new(app_name)
    :subscribe(event, function() set_input_method_function() end)
end

set_app_input_method('Hammerspoon', English, hs.window.filter.windowCreated)
set_app_input_method('Spotlight', English, hs.window.filter.windowCreated)
set_app_input_method('iTerm2', English)
set_app_input_method('WeChat', Chinese)
set_app_input_method('Code', English)
