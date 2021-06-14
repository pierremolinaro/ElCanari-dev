//
//  ApplicationDelegate.swift
//  canari
//
//  Created by Pierre Molinaro on 03/07/2015.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

enum DocumentFormat {
  case binary
  case textual
}

//----------------------------------------------------------------------------------------------------------------------

var gApplicationDelegate : ApplicationDelegate? = nil

//----------------------------------------------------------------------------------------------------------------------

private let SU_LAST_CHECK_TIME = "SULastCheckTime"

//----------------------------------------------------------------------------------------------------------------------

@objc (ApplicationDelegate) final class ApplicationDelegate : NSObject, NSApplicationDelegate, NSMenuItemValidation {

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
  internal var mHandledFiles = [String] ()
  internal var mTotalFileCount = 0
  internal var mHandledFileCount = 0
  internal var mStartDate = Date ()

  //····················································································································
  //  DO NOT OPEN A NEW DOCUMENT ON LAUNCH
  //····················································································································

  func applicationShouldOpenUntitledFile (_ application : NSApplication) -> Bool {
    // NSLog (@"%s", __PRETTY_FUNCTION__) ;
    return false
  }

  //····················································································································

  func applicationDidFinishLaunching (_ notification : Notification) {
    self.mMaintenanceLogTextField?.stringValue = ""
    self.checkForLibraryUpdateAtLaunch ()
    instanciateDebugMenuVisibilityObjectOnDidFinishLaunchingNotification ()
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
  //   SAVE ALL ACTION
  //····················································································································

  @IBAction func saveAllAction (_ inSender : Any?) {
    for document in NSDocumentController.shared.documents {
      document.save (inSender)
    }
  }

  //····················································································································
  // Menu Events
  //····················································································································

  func validateMenuItem (_ inMenuItem : NSMenuItem) -> Bool {
    let validate : Bool
    let action = inMenuItem.action
    if action == #selector (Self.setBinaryFormatAction (_:)) {
      validate = false
      inMenuItem.state = .off
    }else if action == #selector (Self.setTextualFormatAction (_:)) {
      validate = false
      inMenuItem.state = .off
    }else if action == #selector (Self.actionNewProjectDocument (_:)) {
      validate = true
    }else if action == #selector (Self.actionNewMergerDocument (_:)) {
      validate = true
    }else if action == #selector (Self.actionNewSymbolDocument (_:)) {
      validate = true
    }else if action == #selector (Self.actionNewPackageDocument (_:)) {
      validate = true
    }else if action == #selector (Self.actionNewDeviceDocument (_:)) {
      validate = true
    }else if action == #selector (Self.actionNewFontDocument (_:)) {
      validate = true
    }else if action == #selector (Self.actionNewArtworkDocument (_:)) {
      validate = true
    }else{
      validate = false
    }
    // NSLog ("VALIDATE \(action) -> \(validate)")
    return validate
  }

  //····················································································································
  //   FORMAT ACTIONS
  //····················································································································

  @objc func setBinaryFormatAction (_ inSender : Any?) {
  }

  //····················································································································

  @objc func setTextualFormatAction (_ inSender : Any?) {
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
//  ELCANARI VERSION
//----------------------------------------------------------------------------------------------------------------------

func ElCanariApplicationVersionString () -> String {
  let appVersion = Bundle.main.infoDictionary? ["CFBundleShortVersionString"] as? String
  return appVersion ?? "Unknown"
}

//----------------------------------------------------------------------------------------------------------------------
