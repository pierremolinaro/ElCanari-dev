//
//  ApplicationDelegate.swift
//  canari
//
//  Created by Pierre Molinaro on 03/07/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let SU_LAST_CHECK_TIME = "SULastCheckTime"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc (ApplicationDelegate) class ApplicationDelegate : NSObject, NSApplicationDelegate {

  @IBOutlet private var mCanariAppUpdaterSettings : CanariAppUpdaterSettings? = nil // Only for retaining object

  //····················································································································
  //  DO NOT OPEN A NEW DOCUMENT ON LAUNCH
  //····················································································································

  func applicationShouldOpenUntitledFile (_ application : NSApplication) -> Bool {
    // NSLog (@"%s", __PRETTY_FUNCTION__) ;
    return false
  }

  //····················································································································

  func applicationDidFinishLaunching (_ notification: Notification) {
    if g_Preferences?.checkForSystemLibraryAtStartUp ?? false {
      if let logTextView = g_Preferences?.mLibraryUpdateLogTextView {
        let lastCheckDate = g_Preferences?.mLastSystemLibraryCheckTime ?? Date ()
        var nextInterval = 24.0 * 3600.0  // One day
        if let tag = g_Preferences?.systemLibraryCheckTimeInterval {
          if tag == 1 {
            nextInterval *= 7.0 // One week
          }else if tag == 2 {
            nextInterval *= 30.0 // One month
          }
        }
        let checkDate = Date (timeInterval: nextInterval, since:lastCheckDate)
        if checkDate < Date () {
          performLibraryUpdate (nil, logTextView)
          g_Preferences?.mLastSystemLibraryCheckTime = Date ()
        }
      }else{
        NSLog ("g_Preferences?.mLibraryUpdateLogTextView is nil")
      }
    }
  //--- Observe last update application last check time
    UserDefaults.standard.addObserver (
      self,
      forKeyPath: SU_LAST_CHECK_TIME,
      options: .new,
      context: nil
    )
    self.updateApplicationLastCheckTime ()
  }

  //····················································································································

  fileprivate func updateApplicationLastCheckTime () {
    if let lastCheckTimeTextField = g_Preferences?.mSULastCheckTimeTextField {
      if let date = UserDefaults.standard.value (forKey: SU_LAST_CHECK_TIME) {
        lastCheckTimeTextField.objectValue = date
      }else{
        lastCheckTimeTextField.objectValue = "—"
      }
    }
  }

  //····················································································································

  override func observeValue (forKeyPath keyPath: String?,
                              of object: Any?,
                              change: [NSKeyValueChangeKey : Any]?,
                              context: UnsafeMutableRawPointer?) {
    if keyPath == SU_LAST_CHECK_TIME {
      self.updateApplicationLastCheckTime ()
    }else{
      super.observeValue (forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  //····················································································································

  deinit {
    UserDefaults.standard.removeObserver (self, forKeyPath:SU_LAST_CHECK_TIME, context: nil)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
