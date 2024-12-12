import XMonad
import System.IO
import System.Exit
import Data.Monoid
import XMonad.Layout.Spacing
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import Graphics.X11.ExtraTypes.XF86
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Hooks.InsertPosition (insertPosition, Focus(Newer), Position(End))

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal           = "alacritty"
myFocusFollowsMouse  = True
myClickJustFocuses   = False
myBorderWidth        = 2
myModMask            = mod4Mask
myWorkspaces         = ["1","2","3","4","5","6","7","8","9"]
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#00ff00"
myBrowser            = "google-chrome-stable"
myMenu               = "rofi -show drun -theme launchers/gridmenu"
myFileManager        = "nautilus"
myTextEditor         = "alacritty nvim"
myNoteTaker          = "obsidian"

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm,               xK_n     ), refresh)
    , ((modm,               xK_p     ), spawn myMenu)
    , ((modm,               xK_h     ), sendMessage Shrink)
    , ((modm,               xK_l     ), sendMessage Expand)
    , ((modm,               xK_e     ), spawn myFileManager)
    , ((modm,               xK_Tab   ), windows W.focusDown)
    , ((modm,               xK_j     ), windows W.focusDown)
    , ((modm,               xK_k     ), windows W.focusUp  )
    , ((modm,               xK_Return), windows W.swapMaster)
    , ((modm,               xK_space ), sendMessage NextLayout)
    , ((modm,               xK_m     ), windows W.focusMaster  )
    , ((modm,               xK_comma ), sendMessage (IncMasterN 1))
    , ((modm,               xK_period), sendMessage (IncMasterN (-1)))
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    , ((modm,               xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    , ((modm .|. shiftMask, xK_c     ), kill)
    , ((modm .|. shiftMask, xK_p     ), spawn myBrowser)
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp)
    , ((modm .|. shiftMask, xK_o     ), spawn myNoteTaker)
    , ((modm .|. shiftMask, xK_i     ), spawn myTextEditor)
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown)
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    , ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))

    , ((0, xF86XK_AudioMute          ), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    , ((0, xF86XK_AudioLowerVolume   ), spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
    , ((0, xF86XK_AudioRaiseVolume   ), spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")

    -- Workspace Navigation
    , ((modm, xK_1), windows $ W.greedyView "1")
    , ((modm, xK_2), windows $ W.greedyView "2")
    , ((modm, xK_3), windows $ W.greedyView "3")
    , ((modm, xK_4), windows $ W.greedyView "4")
    , ((modm, xK_5), windows $ W.greedyView "5")
    , ((modm, xK_6), windows $ W.greedyView "6")
    , ((modm, xK_7), windows $ W.greedyView "7")
    , ((modm, xK_8), windows $ W.greedyView "8")
    , ((modm, xK_9), windows $ W.greedyView "9")

    -- Workspace Shifting
    , ((modm .|. shiftMask, xK_1), windows $ W.shift "1")
    , ((modm .|. shiftMask, xK_2), windows $ W.shift "2")
    , ((modm .|. shiftMask, xK_3), windows $ W.shift "3")
    , ((modm .|. shiftMask, xK_4), windows $ W.shift "4")
    , ((modm .|. shiftMask, xK_5), windows $ W.shift "5")
    , ((modm .|. shiftMask, xK_6), windows $ W.shift "6")
    , ((modm .|. shiftMask, xK_7), windows $ W.shift "7")
    , ((modm .|. shiftMask, xK_8), windows $ W.shift "8")
    , ((modm .|. shiftMask, xK_9), windows $ W.shift "9")

    -- Screen Navigation
    , ((modm, xK_w), screenWorkspace 0 >>= flip whenJust (windows . W.view))
    , ((modm, xK_e), screenWorkspace 1 >>= flip whenJust (windows . W.view))
    , ((modm, xK_r), screenWorkspace 2 >>= flip whenJust (windows . W.view))

    -- Screen Shifting
    , ((modm .|. shiftMask, xK_w), screenWorkspace 0 >>= flip whenJust (windows . W.shift))
    , ((modm .|. shiftMask, xK_e), screenWorkspace 1 >>= flip whenJust (windows . W.shift))
    , ((modm .|. shiftMask, xK_r), screenWorkspace 2 >>= flip whenJust (windows . W.shift))
    ]

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
    ]

myLayoutHook = tiled ||| Mirror tiled ||| Full
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 1/2
     delta   = 3/100

myManageHook = composeAll
    [insertPosition End Newer
    ,className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

myLogHook = return ()

myStartupHook = do
    spawnOnce "picom -f &"
    spawnOnce "volumeicon &"
    spawnOnce "blueman-applet &"
    spawnOnce "xscreensaver &"
    spawnOnce "stalonetray &"
    spawnOnce "xscreensaver -no-splash &"
    spawnOnce "nm-applet --sm-disable"
    spawnOnce "amixer set Master playback 100% &"
    spawnOnce "feh --bg-scale /home/shawal/wallpaper.jpg &"
    spawnOnce "setxkbmap -layout us,ara -option 'grp:alt_shift_toggle'"
    spawnOnce "xmodmap -e \"keycode 66 = Escape\""
    spawnOnce "xmodmap -e \"keycode 9  = Caps_Lock\""
    spawnOnce "xmodmap -e \"clear Lock\""
    spawnOnce "bash .screenlayout/arandr.sh"
    spawnOnce "xset -dpms"
    spawnOnce "setterm -blank 0 -powerdown 0"
    spawnOnce "xset s off"

myBar = "xmobar"
myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">" }
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

main = xmonad =<< statusBar myBar myPP toggleStrutsKey defaults
-- main = xmonad $ ewmhFullscreen $ ewmh $ defaults
defaults = def {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = spacingWithEdge 5 $ myLayoutHook,
        manageHook         = myManageHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
