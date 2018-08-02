local KEY_CODE_KANA = 0x68


local function keyCode(key, modifiers)
   modifiers = modifiers or {}
   return function()
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
      hs.timer.usleep(1000)
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()      
   end
end

local function remapKey(modifiers, key, keyCode)
   hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end

local function disableAllHotkeys()
   for k, v in pairs(hs.hotkey.getHotkeys()) do
      v['_hk']:disable()
   end
end

local function enableAllHotkeys()
   for k, v in pairs(hs.hotkey.getHotkeys()) do
      v['_hk']:enable()
   end
end

local function handleGlobalAppEvent(name, event, app)
   if event == hs.application.watcher.activated then
      -- hs.alert.show(name)
      -- if name == "Microsoft Word" then
      if string.find(name, "Microsoft") then
         enableAllHotkeys()
      else
         disableAllHotkeys()
      end
   end
end

appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()

remapKey({'ctrl'}, 'p', keyCode('up'))
remapKey({'ctrl'}, 'n', keyCode('down'))
remapKey({'ctrl'}, 'b', keyCode('left'))
remapKey({'ctrl'}, 'f', keyCode('right'))

remapKey({'ctrl'}, 'a', keyCode('home'))
remapKey({'ctrl'}, 'e', keyCode('end'))

remapKey({'ctrl'}, 'h', keyCode('delete')) -- backspace
remapKey({'ctrl'}, 'd', keyCode('forwarddelete')) -- delete

remapKey({'alt'}, 'w', keyCode('c', {'cmd'})) -- copy
remapKey({'ctrl'}, 'w', keyCode('x', {'cmd'})) -- cut
remapKey({'ctrl'}, 'y', keyCode('v', {'cmd'})) -- paste

remapKey({'ctrl'}, 'g', keyCode('escape'))
remapKey({'ctrl'}, '/', keyCode('z', {'cmd'}))





local prevKeyCode
local escape = 0x35
local leftCommand = 0x37
local rightCommand = 0x36
local eisuu = 0x66
local kana = 0x68

local function keyStroke(modifiers, character)
    hs.eventtap.keyStroke(modifiers, character)
end

local function jp()
    keyStroke({}, kana)
end

local function eng()
    keyStroke({}, eisuu)
end

local function handleEvent(e)
    local keyCode = e:getKeyCode()
    if keyCode == escape then
        eng()
    end


    local isCmdKeyUp = not(e:getFlags()['cmd']) and e:getType() == hs.eventtap.event.types.flagsChanged
    if isCmdKeyUp and prevKeyCode == leftCommand then
        eng()
    elseif isCmdKeyUp and prevKeyCode == rightCommand then
        jp()
    end

    prevKeyCode = keyCode
end

eventtap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, handleEvent)
eventtap:start()




remapKey({'ctrl'}, 'j', keyCode('kana'))

-- note
-- AquaSKK 総合と ascii だけだと動かなかったが, "ひらがな" を追加すると動く