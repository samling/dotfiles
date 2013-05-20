import XMonad
-- LAYOUTS
import XMonad.Layout.Spacing
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.Circle
-- WINDOW RULES
import XMonad.ManageHook
-- KEYBOARD & MOUSE CONFIG
import XMonad.Util.EZConfig
import XMonad.Actions.FloatKeys
import Graphics.X11.ExtraTypes.XF86
-- STATUS BAR
import XMonad.Hooks.DynamicLog hiding (xmobar, xmobarPP, xmobarColor, sjanssenPP, byorgeyPP)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Dmenu
--import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops hiding (fullscreenEventHook)
import System.IO (hPutStrLn)
--import XMonad.Operations
import qualified XMonad.StackSet as W
import qualified XMonad.Actions.FlexibleResize as FlexibleResize
import XMonad.Util.Run (spawnPipe)
import XMonad.Actions.CycleWS            -- nextWS, prevWS
import Data.List         -- clickable workspaces

-- Bars
myXmonadBar = "dzen2 -e '' -x '0' -y '0' -h '14' -w '1400' -xs '1' -ta 'l' -fg '"++foreground++"' -bg '"++background++"' -fn "++myFont
myStatusBar = "conky -q | dzen2 -e '' -x '1300' -w '766' -h '14' -xs '1' -ta 'r' -bg '"++background++"' -fg '"++foreground++"' -y '0' -fn "++myFont

-- Layout
myLayout = onWorkspace (myWorkspaces !! 0) (avoidStruts (tiledSpace ||| tiled) ||| fullTile)
            $ onWorkspace (myWorkspaces !! 1) (avoidStruts (tiledSpace ||| fullTile) ||| fullScreen)
            $ onWorkspace (myWorkspaces !! 2) (avoidStruts simplestFloat)
            $ avoidStruts ( tiledSpace ||| tiled ||| fullTile )
        where
            tiled           =   spacing 5 $ ResizableTall nmaster delta ratio []
            tiledSpace      =   spacing 60 $ ResizableTall nmaster delta ratio []
            fullScreen      =   noBorders(fullscreenFull Full)
            fullTile        =   ResizableTall nmaster delta ratio []
            borderlessTile  =   noBorders(fullTile)
            -- Default # windows in master pane
            nmaster = 1
            -- Perfecntage of screen to increment when resizing
            delta = 5/100
            -- Default proportion of screen taken up by main pane
            ratio = toRational (2/(1 + sqrt 5 :: Double))

-- Workspaces
myWorkspaces = ["term"
    ,"web"
    ,"float"
    ,"docs"
    ,"tunes"
    ,"mail"]
    where clickable l = [ "^ca(l,xdotool key alt+" ++ show (n) ++ ")" ++ ws ++ "^ca()" | (i,ws) <- zip [1..] l, let n = i]


-- Management hook
myManageHook = composeAll [
    transience
    , resource =? "dmenu" --> doFloat
    , resource =? "mplayer" --> doFloat
    , resource =? "feh" --> doFloat
    , manageDocks]
newManageHook = myManageHook <+> manageHook defaultConfig


-- Log hook
myLogHook h = dynamicLogWithPP ( defaultPP {
    ppCurrent       = dzenColor color2 background . pad
    , ppVisible     = dzenColor color14 background .    pad
    , ppHidden      = dzenColor color14 background .    pad
    , ppHiddenNoWindows = dzenColor color6 background . pad
    , ppWsSep       = ""
    , ppSep         = "   "
    -- To get rid of layout in bar: \(ws:_:t:_) -> [ws]
    , ppOrder       = \(ws:l:t:_) -> [ws,l]
    , ppOutput      = hPutStrLn h
})

-- Main function

main = do
    dzenLeftBar     <-  spawnPipe myXmonadBar
    dzenRightBar    <-  spawnPipe myStatusBar
    xmonad $ ewmh defaultConfig
        {
            terminal        =   myTerminal
          , borderWidth     =   5
          , normalBorderColor = background
          , focusedBorderColor = color6
          , modMask         =   mod1Mask
          , layoutHook      =   smartBorders $ myLayout
          , workspaces      =   myWorkspaces
          , manageHook      =   newManageHook
          , handleEventHook =   fullscreenEventHook <+> docksEventHook
          , startupHook     =   setWMName "LG3D"
          , logHook         =   myLogHook dzenLeftBar
        }

-- Variables
myTerminal=         "terminator"
myBitmapsDir=       "~/.xmonad/dzen2/"
myFont=             "-*-terminus-medium-*-normal-*-10-*-*-*-*-*-*-*"
background=            "#262729"
foreground=            "#f8f8f2"
color0=                "#626262"
color8=                "#626262"
color1=                "#f92671"
color9=                "#ff669d"
color2=                "#a6e22e"
color10=               "#beed5f"
color3=                "#fd971f"
color11=               "#e6db74"
color4=                "#1692d0"
color12=               "#66d9ef"
color5=                "#9e6ffe"
color13=               "#df92f6"
color6=                "#5e7175"
color14=               "#a3babf"
color7=                "#ffffff"
color15=               "#ffffff"
cursorColor=           "#b5d2dd"
