//
//  ApplicationDelegate.swift
//  canari
//
//  Created by Pierre Molinaro on 03/07/2015.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

var gApplicationDelegate : ApplicationDelegate? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let SU_LAST_CHECK_TIME = "SULastCheckTime"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc (ApplicationDelegate) class ApplicationDelegate : NSObject, NSApplicationDelegate {

  //····················································································································
  //  init
  //····················································································································

  override init () {
    super.init ()
    gApplicationDelegate = self
  }

  //····················································································································

  @IBOutlet private var mCanariAppUpdaterSettings : CanariAppUpdaterSettings? = nil // Only for retaining object

  @IBOutlet internal var mOpenAllDialogAccessoryCheckBox : NSButton? = nil

  //····················································································································
  //  Theses outlets are used in ApplicationDelegate-maintenance.swift
  //····················································································································

  @IBOutlet internal var mMaintenanceLogTextView : NSTextView? = nil

  @IBOutlet internal var mMaintenanceLogTextField : NSTextField? = nil

  internal var mCount = 0

  //····················································································································
  //  DO NOT OPEN A NEW DOCUMENT ON LAUNCH
  //····················································································································

  func applicationShouldOpenUntitledFile (_ application : NSApplication) -> Bool {
    // NSLog (@"%s", __PRETTY_FUNCTION__) ;
    return false
  }

  //····················································································································

  func applicationDidFinishLaunching (_ notification: Notification) {
    self.mMaintenanceLogTextField?.stringValue = ""
    self.checkForLibraryUpdateAtLaunch ()
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
    UserDefaults.standard.removeObserver (self, forKeyPath: SU_LAST_CHECK_TIME, context: nil)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
