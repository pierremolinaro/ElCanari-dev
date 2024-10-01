//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 14/06/2021.
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

fileprivate let SHOW_DEBUG_MENU_VISIBLITY_KEY = "show.debug.menu"

//--------------------------------------------------------------------------------------------------
//   Public functions
//--------------------------------------------------------------------------------------------------

@MainActor func instanciateDebugMenuObjectOnWillFinishLaunchingNotification () {
  gDebugMenuVisibility = DebugMenuVisibility ()
}

//--------------------------------------------------------------------------------------------------

@MainActor func setDebugMenuVisibility (_ inFlag : Bool) {
  let debugMenu : DebugMenuVisibility
  if let menu = gDebugMenuVisibility {
    debugMenu = menu
  }else{
    debugMenu = DebugMenuVisibility ()
    gDebugMenuVisibility = debugMenu
  }
  debugMenu.setVisibility (inFlag)
}

//--------------------------------------------------------------------------------------------------

@MainActor func debugMenuVisibility () -> Bool {
  let debugMenu : DebugMenuVisibility
  if let menu = gDebugMenuVisibility {
    debugMenu = menu
  }else{
    debugMenu = DebugMenuVisibility ()
    gDebugMenuVisibility = debugMenu
  }
  return debugMenu.visibility ()
}

//--------------------------------------------------------------------------------------------------
//   Private entities
//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gDebugMenuVisibility : DebugMenuVisibility? = nil

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate final class DebugMenuVisibility {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mDebugMenuItem = NSMenuItem (title: "Debug", action: nil, keyEquivalent: "")
  private var mIsVisible : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.mIsVisible = UserDefaults.standard.bool (forKey: SHOW_DEBUG_MENU_VISIBLITY_KEY)
    let menu = NSMenu (title: "Debug")
    self.mDebugMenuItem.submenu = menu

    appendAllocationDebugMenuItems (menu)
    appendShowTransientEventLogWindowMenuItem (menu)
    appendShowDocumentFileOperationDurationWindowMenuItem (menu)
    appendDebugAutoLayoutMenuItem (menu)

    self.updateDebugMenuVisibility ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setVisibility (_ inFlag : Bool) {
    if self.mIsVisible != inFlag {
      UserDefaults.standard.setValue (inFlag, forKey: SHOW_DEBUG_MENU_VISIBLITY_KEY)
      self.mIsVisible = inFlag
      self.updateDebugMenuVisibility ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func visibility () -> Bool {
    return self.mIsVisible
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateDebugMenuVisibility () {
    if let mainMenu = NSApplication.shared.mainMenu {
      if self.mIsVisible {
        mainMenu.addItem (self.mDebugMenuItem)
      }else if mainMenu.index (of: self.mDebugMenuItem) >= 0 {
        mainMenu.removeItem (self.mDebugMenuItem)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
