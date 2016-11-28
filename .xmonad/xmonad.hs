-- Everythig here is copy-pasted from several sources, notably Miika's:
-- https://github.com/nablaa/dotfiles/blob/master/.xmonad/xmonad.hs
import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.Grid
import XMonad.Layout.Reflect
import XMonad.Layout.MouseResizableTile
import XMonad.StackSet hiding (workspaces)
import XMonad.Util.EZConfig(additionalKeys)
import qualified Data.Map as M

-- Workspaces
myWorkspaces = ["0","1","2","3","4","5","6","7","8","9"]

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
    , ((myModMask .|. controlMask, xK_l),
        spawn "gnome-screensaver-command --lock")
    , ((shiftMask, 0xff61),
        spawn "sleep 0.2; scrot -s '%H_%M_%S__%d_%m_%y.png' -e 'mv $f ~/screenshots'")
    ]
    -- Switch to additional workspaces (other than 1-9, which is the default)
    ++
    [((m .|. myModMask, k), windows $ f i)
    | (i, k) <- zip myWorkspaces [xK_0, xK_1, xK_2, xK_3, xK_4, xK_5, xK_6, xK_7, xK_8, xK_9]
    , (f, m) <- [(greedyView, 0), (shift, shiftMask)]]

-- Layout
myLayoutHook = smartBorders $ mouseResizableTile { draggerType = BordersDragger }
                              ||| mouseResizableTile { isMirrored = True,
                                                       draggerType = BordersDragger }
                              ||| Grid
                              ||| noBorders Full

-- Specific window rules
myManageHook = composeAll
    [ isDialog                                              --> doFloat
    , className =? "MPlayer"                                --> doFloat
    , className =? "Gimp"                                   --> doFloat
    , resource  =? "desktop_window"                         --> doIgnore
    , resource  =? "kdesktop"                               --> doIgnore
    , className =? "Thunderbird"                            --> doShift "1"
    , stringProperty "WM_NAME" =? "gist"                    --> doFloat
    , stringProperty "WM_NAME" =? "notes"                   --> doFloat
    , stringProperty "WM_NAME" =? "mixer"                   --> doFloat
    , stringProperty "WM_NAME" =? "TTCN-3 Test Executor"    --> doFloat
    , stringProperty "WM_NAME" =? "TTCN-3 Log Monitor"      --> doFloat
    , stringProperty "WM_NAME" =? "Buddy List"              --> doFloat
-- Thesis
    , stringProperty "WM_NAME" =? "Plot area"               --> doFloat
    , stringProperty "WM_NAME" =? "Data table"              --> doFloat
    , stringProperty "WM_NAME" =? "Data selection"          --> doFloat
    , manageDocks <+> manageHook defaultConfig
    ]


-- Main
main = do
    xmonad $ defaultConfig
        { focusedBorderColor    = myFocusedBorderColor
        , layoutHook            = myLayoutHook
        , manageHook            = myManageHook
        , modMask               = myModMask
        , workspaces            = myWorkspaces
        , normalBorderColor     = myNormalBorderColor } `additionalKeys` myKeys
