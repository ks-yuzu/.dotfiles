-- file : ~/.xmonad/xmonad.hs

-- import System.IO

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageDocks   (ToggleStruts(..),avoidStruts,docks,manageDocks)
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run  -- spawnPipe, hPutStrLn
import XMonad.Util.EZConfig  --additionalKeys

-- config
import XMonad.Config.Desktop

-- WS
import qualified XMonad.StackSet as W
import XMonad.Util.WorkspaceCompare
import XMonad.Actions.CycleWS

-- defalut WS
import Data.List -- isPrefixOf,isSuffixOf,isInfixOfを使用可能に
import Control.Monad (liftM2)

-- for Java Swing
import XMonad.Hooks.ICCCMFocus

import Graphics.X11.ExtraTypes.XF86 (
  xF86XK_AudioRaiseVolume,
  xF86XK_AudioLowerVolume,
  xF86XK_AudioMute,
  xF86XK_MonBrightnessDown,
  xF86XK_MonBrightnessUp
  )

-- for libreoffice 
import XMonad.Hooks.EwmhDesktops

main :: IO()
main = do
    myStatusBar <- spawnPipe "/usr/bin/xmobar"
    -- xmonad $ ewmh desktopConfig {
    xmonad $ docks desktopConfig {
        modMask     = myModMask,  -- mod1Mask : Alt,  mod4Mask : Super
        terminal    = "urxvt -e tmux",
        borderWidth = 1,
        normalBorderColor  = "#777777",  -- 非アクティブウィンドウの枠色
        focusedBorderColor = "#ff4500",  -- アクティブウィンドウの枠色
        layoutHook  = myLayoutHook,
        manageHook  = myManageHook <+> myManageHookFloat,
        startupHook = myStartupHook,
        handleEventHook = docksEventHook <+> handleEventHook desktopConfig,
        logHook     = do
            myLogHook myStatusBar
            takeTopFocus
    }
      `additionalKeys` myAdditionalKeys
      `additionalKeysP` myAdditionalKeysP
      `removeKeysP`     ["M-q"]


myModMask = mod4Mask
myLayoutHook = avoidStruts $ layoutHook def
myManageHook = manageDocks <+> manageHook desktopConfig
myLogHook h = dynamicLogWithPP xmobarPP {
    ppOutput = hPutStrLn h
}

myStartupHook = do
  spawn "(ps aux | grep '[e]macs') || emacs"
  spawn "(ps aux | grep '[u]rxvt') || urxvt -e tmux"
  -- tmux attach -t $(tmux list-sessions | head -n1 | perl -ne '/^(\d+)/ and print $1')
  spawn "hsetroot -solid '#000000' && xcompmgr"
  spawn "xhost +SI:localuser:root && sudo xkeysnail .xkeysnail-config.py"
  spawn "dropbox.py start"

myAdditionalKeys =
  [
   -- key binding
   --  ("M-S-n"  , moveTo Next NonEmptyWS)
   -- ,("M-S-p"  , moveTo Prev NonEmptyWS)
   -- ,("M-C-S-n", do t <- findWorkspace getSortByIndex Next EmptyWS 1
   --                 (windows . W.shift) t
   --                 (windows . W.greedyView) t
   --  )
   -- ,("M-C-S-p", do t <- findWorkspace getSortByIndex Prev EmptyWS 1
   --                 (windows . W.shift) t
   --                 (windows . W.greedyView) t
   --  )
   -- ,("C-M-n"  , shiftTo Next EmptyWS)
   -- ,("C-M-p"  , shiftTo Prev EmptyWS)
   -- ,("M-S-r"  , spawn "killall xmobar; xmonad --recompile && xmonad --restart")
    ((0, xF86XK_AudioLowerVolume ), unsafeSpawn "amixer set Master 2dB-")
   ,((0, xF86XK_AudioRaiseVolume ), unsafeSpawn "amixer set Master 2dB+")
   ,((0, xF86XK_AudioMute        ), unsafeSpawn "amixer -D pulse set Master 1+ toggle")
   ,((0, xF86XK_MonBrightnessDown), unsafeSpawn "sudo brightness --dec 5")
   ,((0, xF86XK_MonBrightnessUp  ), unsafeSpawn "sudo brightness --inc 5")
  ]


myAdditionalKeysP =
  [
   -- key binding
   --  ("M-S-n"  , moveTo Next NonEmptyWS)
   -- ,("M-S-p"  , moveTo Prev NonEmptyWS)
   -- ,("M-C-S-n", do t <- findWorkspace getSortByIndex Next EmptyWS 1
   --                 (windows . W.shift) t
   --                 (windows . W.greedyView) t
   --  )
   -- ,("M-C-S-p", do t <- findWorkspace getSortByIndex Prev EmptyWS 1
   --                 (windows . W.shift) t
   --                 (windows . W.greedyView) t
   --  )
   -- ,("C-M-n"  , shiftTo Next EmptyWS)
   -- ,("C-M-p"  , shiftTo Prev EmptyWS)
     ("M-S-k"  , spawn "/usr/bin/screenkey --no-systray")
    ,("M-S-l"  , spawn "ps aux | grep '[s]creenkey' | awk '{print $2}' | xargs kill")
    ,("M-S-r"  , spawn "killall xmobar; xmonad --recompile && xmonad --restart")
  ]


myManageHookFloat = composeAll
    [
      className =? "Gimp"             --> doFloat
    -- , className =? "Tk"               --> doFloat
    -- , className =? "mplayer2"         --> doCenterFloat
    -- , className =? "mpv"              --> doCenterFloat
    -- , className =? "feh"              --> doCenterFloat
    -- , className =? "Display.im6"      --> doCenterFloat
    -- , className =? "Shutter"          --> doCenterFloat
    -- , className =? "Thunar"           --> doCenterFloat
    -- , className =? "Nautilus"         --> doCenterFloat
    -- , className =? "Plugin-container" --> doCenterFloat
         -- className =? "Screenkey"        --> (doRectFloat $ W.RationalRect 0.0 0.9 0.5 0.1)
    -- , className =? "Websearch"        --> doCenterFloat
    -- , className =? "XClock"           --> doSideFloat NE
    -- , title     =? "Speedbar"         --> doCenterFloat
    -- , title     =? "urxvt_float"      --> doSideFloat SC
    -- , isFullscreen                    --> doFullFloat
    -- , isDialog                        --> doCenterFloat
    -- , stringProperty "WM_NAME" =? "LINE" --> (doRectFloat $ W.RationalRect 0.60 0.1 0.39 0.82)
    -- , stringProperty "WM_NAME" =? "Google Keep" --> (doRectFloat $ W.RationalRect 0.3 0.1 0.4 0.82)
    -- , stringProperty "WM_NAME" =? "tmptex.pdf - 1/1 (96 dpi)" --> (doRectFloat $ W.RationalRect 0.29 0.25 0.42 0.5)
    -- , stringProperty "WM_NAME" =? "Figure 1" --> doFloat
    ]

-- -- setting default workspace
-- myManageHookShift = composeAll
--     [ className =? "Firefox"                --> viewShift "2"
--     , fmap ("Gimp" `isPrefixOf`) className  --> viewShift "9"
--     , className =? "emacs"                  --> viewShift "1"
--     ]
--     where viewShift = doF . liftM2 (.) W.view W.shift





-- 95 ：login:Penguin：2016/04/04(月) 22:39:38.92 ID:amRINh5A
--     と思ったら、これだとfull layoutの際にxmobarが隠れないままになる。

--     myEventHook = handleEventHook defaultConfig <+> docksEventHook

--     こいつを、main = do 以下に追加で直りやした。

-- 96 ：login:Penguin：2016/04/04(月) 23:40:29.61 ID:msihTCeC
--     >>93-95
--     docksEventHookで正解みたいですね
--     こっちも直りました 
