hs.console.clearConsole()

require("audio")
require("input")
require("screen")
require("peripheral")

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

hs.alert.show("Config loaded")
