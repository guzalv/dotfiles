import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.Grid
import XMonad.Layout.Reflect
import XMonad.Layout.MouseResizableTile
import XMonad.Util.EZConfig(additionalKeys)
import qualified Data.Map as M

-- Borders
myNormalBorderColor  = "#777777"
myFocusedBorderColor = "#ffffff"

-- Keys
myModMask = mod1Mask
myKeys =
    [ ((myModMask, xK_Up), sendMessage ShrinkSlave)
    , ((myModMask, xK_Down), sendMessage ExpandSlave)
    , ((myModMask .|. controlMask, xK_Page_Up), spawn "set_volume up")
    , ((myModMask .|. controlMask, xK_Page_Down), spawn "set_volume down")
    , ((myModMask .|. controlMask, xK_End), spawn "set_volume toggle")
    , ((myModMask .|. controlMask, xK_l), spawn "gnome-screensaver-command --lock")
    , ((shiftMask, 0xff61), spawn "sleep 0.2; scrot -s '%H_%M_%S__%d_%m_%y.png' -e 'mv $f ~/screenshots'")
    ]

-- Layout
myLayoutHook = smartBorders $ mouseResizableTile { draggerType = BordersDragger }
                              ||| mouseResizableTile { isMirrored = True,
                                                       draggerType = BordersDragger }
                              ||| Grid
                              ||| noBorders Full

-- Specific window rules
myManageHook = composeAll
    [ isDialog                      --> doFloat
    , className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , className =? "Thunderbird"    --> doShift "1"
    , stringProperty "WM_NAME" =? "gist"                            --> doFloat
    , stringProperty "WM_NAME" =? "notes"                           --> doFloat
    , stringProperty "WM_NAME" =? "mixer"                           --> doFloat
    , stringProperty "WM_NAME" =? "TTCN-3 Test Executor"            --> doFloat
    , stringProperty "WM_NAME" =? "TTCN-3 Log Monitor"              --> doFloat
    , stringProperty "WM_NAME" =? "Buddy List"                      --> doFloat
-- Thesis
    , stringProperty "WM_NAME" =? "Plot area"                       --> doFloat
    , stringProperty "WM_NAME" =? "Data table"                      --> doFloat
    , stringProperty "WM_NAME" =? "Data selection"                  --> doFloat
    , manageDocks <+> manageHook defaultConfig
    ]


-- Main
main = do
    xmonad $ defaultConfig
        { focusedBorderColor = myFocusedBorderColor
        , layoutHook        = myLayoutHook
        , manageHook        = myManageHook
        , modMask           = myModMask
        , normalBorderColor  = myNormalBorderColor } `additionalKeys` myKeys
