-- Everythig here is copy-pasted from several sources, notably Miika's:
-- https://github.com/nablaa/dotfiles/blob/master/.xmonad/xmonad.hs
import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.Grid
import XMonad.Layout.Reflect
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MouseResizableTile
import XMonad.Util.EZConfig(additionalKeys)
import qualified Data.Map as M

-- Borders
myNormalBorderColor  = "#777777"
myFocusedBorderColor = "#ffffff"

-- Keys
myModMask = mod1Mask
myKeys =
    [ ((myModMask, xK_Up),                          sendMessage ShrinkSlave)
    , ((myModMask, xK_Down),                        sendMessage ExpandSlave)
    , ((myModMask .|. controlMask, xK_Page_Up),     spawn "set_volume up")
    , ((myModMask .|. controlMask, xK_Page_Down),   spawn "set_volume down")
    , ((myModMask .|. controlMask, xK_End),         spawn "set_volume toggle")
    , ((myModMask .|. controlMask, xK_l),           spawn "lock_screen")
    , ((myModMask .|. shiftMask, xK_s),
        spawn "gnome-terminal --window-with-profile=smaller")
    , ((shiftMask, 0xff61),
        spawn "sleep 0.2; scrot -s '%H_%M_%S__%d_%m_%y.png' -e 'mv $f ~/screenshots'")
    ]

-- Layout
myLayoutHook = smartBorders $ mouseResizableTile { draggerType = BordersDragger }
                              ||| mouseResizableTile { isMirrored = True,
                                                       draggerType = BordersDragger }
                              ||| Grid
                              ||| ThreeCol 1 (3/100) (1/3)
                              ||| noBorders Full

-- Specific window rules
myManageHook = composeAll
    [ isDialog                                                      --> doFloat
    , stringProperty "WM_NAME" =? "Appointments"                    --> doFloat
    , stringProperty "WM_NAME" =? "gist"                            --> doFloat
    , stringProperty "WM_NAME" =? "notes"                           --> doFloat
    , stringProperty "WM_NAME" =? "mixer"                           --> doFloat
    , stringProperty "WM_NAME" =? "TTCN-3 Test Executor"            --> doFloat
    , stringProperty "WM_NAME" =? "TTCN-3 Log Monitor"              --> doFloat
    , stringProperty "WM_NAME" =? "Buddy List"                      --> doFloat
    , manageDocks <+> manageHook defaultConfig
    ]


-- Main
main = do
    xmonad $ defaultConfig
        { focusedBorderColor    = myFocusedBorderColor
        , layoutHook            = myLayoutHook
        , manageHook            = myManageHook
        , modMask               = myModMask
        , normalBorderColor     = myNormalBorderColor } `additionalKeys` myKeys
