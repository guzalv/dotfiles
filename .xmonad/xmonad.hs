import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.Grid
import XMonad.Layout.Reflect
import XMonad.Layout.MouseResizableTile
import qualified Data.Map as M


-- Borders
myNormalBorderColor  = "#115511"
myFocusedBorderColor = "#00ff00"

-- Keys
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList
    [ ((modm, xK_Up ), sendMessage ShrinkSlave)
        , ((modm, xK_Down ), sendMessage ExpandSlave)
        , ((modm .|. controlMask, xK_l ), spawn "gnome-screensaver-command --lock")
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
    , stringProperty "WM_NAME" =? "TTCN-3 Test Executor"            --> doFloat
    , stringProperty "WM_NAME" =? "Select Config (MMGW) - LMF"      --> doFloat
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
        , keys = myKeys <+> keys defaultConfig
        , normalBorderColor  = myNormalBorderColor }
