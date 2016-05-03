-- file : ~/.xmonad/xmonad.hs

-- import System.IO

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run  -- spawnPipe, hPutStrLn
import XMonad.Util.EZConfig  --additionalKeys

-- WS
import qualified XMonad.StackSet as W
import XMonad.Util.WorkspaceCompare
import XMonad.Actions.CycleWS

-- defalut WS
import Data.List -- isPrefixOf,isSuffixOf,isInfixOfを使用可能に
import Control.Monad (liftM2)

-- for Java Swing
import XMonad.Hooks.ICCCMFocus

-- for Chrome full screent
-- import XMonad.Hooks.EwmhDesktops

main :: IO()
main = do
    myStatusBar <- spawnPipe "~/.cabal/bin/xmobar"
    xmonad $ def{
        modMask     = myModMask,  -- mod1Mask : Alt,  mod4Mask : Super
        terminal    = "urxvt -e tmux",
        borderWidth = 1,
        layoutHook  = myLayoutHook,
        manageHook  = myManageHook,
        startupHook = myStartupHook,
        logHook     = do
            myLogHook myStatusBar
            takeTopFocus
--        handleEventHook = fullscreenEventHook
    }
      `additionalKeysP` myAdditionalKeys
      `removeKeysP`     ["M-q"]
      

myModMask = mod4Mask
myLayoutHook = avoidStruts $ layoutHook def
myManageHook = manageDocks <+> manageHook def
myLogHook h = dynamicLogWithPP xmobarPP {
    ppOutput = hPutStrLn h
}

myStartupHook = do
  spawn "sleep 2 && emacs"
  spawn "sleep 1 && urxvt -e tmux"
-- spawn "dropbox.py start"


myAdditionalKeys =
  [
   -- key binding
    ("M-S-n"  , moveTo Next NonEmptyWS)
   ,("M-S-p"  , moveTo Prev NonEmptyWS)
   ,("M-C-S-n", do t <- findWorkspace getSortByIndex Next EmptyWS 1
                   (windows . W.shift) t
                   (windows . W.greedyView) t
    )
   ,("M-C-S-p", do t <- findWorkspace getSortByIndex Prev EmptyWS 1
                   (windows . W.shift) t
                   (windows . W.greedyView) t
    )
   ,("C-M-n"  , shiftTo Next EmptyWS)
   ,("C-M-p"  , shiftTo Prev EmptyWS)
   ,("M-S-r"  , spawn "killall xmobar; xmonad --recompile && xmonad --restart")
  ]


          
-- -- setting default workspace
-- myManageHookShift = composeAll
--     [ className =? "Firefox"                --> viewShift "2"
--     , fmap ("Gimp" `isPrefixOf`) className  --> viewShift "9"
--     , className =? "emacs"                  --> viewShift "1"
--     ]
--     where viewShift = doF . liftM2 (.) W.view W.shift

