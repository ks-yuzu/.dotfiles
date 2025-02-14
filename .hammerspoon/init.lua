-- ターミナルでctrl + j
local function terminalEvent(name, event, app)
  if event == hs.application.watcher.activated then
    if name == 'ターミナル' or name == 'iTerm2' then
        hs.hotkey.bind({"ctrl"}, "j", function()
            hs.eventtap.keyStroke({}, 104, 0)
        end)
    else
        hs.hotkey.disableAll("ctrl", "j")
    end
  end
end

terminalWatch = hs.application.watcher.new(terminalEvent)
terminalWatch:start()

