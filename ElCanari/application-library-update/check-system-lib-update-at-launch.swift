//
//  check-system-lib-update-at-launch.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/07/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension ApplicationDelegate {

  //····················································································································

  internal func checkForLibraryUpdateAtLaunch () {
    self.mMaintenanceLogTextField?.stringValue = ""
    if preferences_checkForSystemLibraryAtStartUp {
      if let logTextView = g_Preferences?.mLibraryUpdateLogTextView {
        // NSLog ("g_Preferences?.mLastSystemLibraryCheckTime \(g_Preferences?.mLastSystemLibraryCheckTime)")
        let lastCheckDate = preferences_mLastSystemLibraryCheckTime
        var nextInterval = 24.0 * 3600.0  // One day
        let tag = preferences_systemLibraryCheckTimeInterval
        if tag == 1 {
          nextInterval *= 7.0 // One week
        }else if tag == 2 {
          nextInterval *= 30.0 // One month
        }
        let checkDate = Date (timeInterval: nextInterval, since:lastCheckDate)
        if checkDate < Date () {
          startLibraryUpdateOperation (nil, logTextView)
          preferences_mLastSystemLibraryCheckTime = Date ()
        }
      }else{
        NSLog ("g_Preferences?.mLibraryUpdateLogTextView is nil")
      }
    }
  }

  //····················································································································
}

//----------------------------------------------------------------------------------------------------------------------
