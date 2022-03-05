//
//  ApplicationDelegate.swift
//  canari
//
//  Created by Pierre Molinaro on 03/07/2015.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa
import Sparkle

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum DocumentFormat {
  case binary
  case textual
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

var gApplicationDelegate : ApplicationDelegate? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SU_LAST_CHECK_TIME = "SULastCheckTime"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc (ApplicationDelegate) final class ApplicationDelegate : NSObject, NSApplicationDelegate, NSMenuItemValidation {

  //····················································································································
  //  init
  //····················································································································

  override init () {
    super.init ()
    gApplicationDelegate = self
  }

  //····················································································································
  //  Outlets
  //····················································································································

  @IBOutlet var mCheckNowForUpdateMenuItem : NSMenuItem? = nil

  @IBOutlet var mOpenAllDialogAccessoryCheckBox : NSButton? = nil

  //····················································································································
  //  Theses outlets are used in ApplicationDelegate-batch.swift
  //····················································································································

  @IBOutlet var mMaintenanceLogTextView : NSTextView? = nil

  @IBOutlet var mMaintenanceLogTextField : NSTextField? = nil

  var mCount = 0
  var mHandledFiles = [String] ()
  var mTotalFileCount = 0
  var mHandledFileCount = 0
  var mStartDate = Date ()

  //····················································································································
  // Sparkle 2.x
  //····················································································································

  let mUpdaterController = Sparkle.SPUStandardUpdaterController (updaterDelegate: nil, userDriverDelegate: nil)

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
    self.addAutoLayoutUserInterfaceStyleObserver ()
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
    }else if action == #selector (Self.actionOpenArtworkInLibrary (_:)) {
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
  //   AutoLayout user interface style
  //····················································································································

  fileprivate var mUserInterfaceStyleObserver : EBObservablePropertyController? = nil

  //····················································································································

  fileprivate func addAutoLayoutUserInterfaceStyleObserver () {
    self.mUserInterfaceStyleObserver = EBObservablePropertyController (
      observedObjects: [preferences_mAutoLayoutStyle_property],
      callBack: {
         changeAutoLayoutUserInterfaceStyle (to: preferences_mAutoLayoutStyle)
      }
    )
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  ELCANARI VERSION
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func ElCanariApplicationVersionString () -> String {
  let appVersion = Bundle.main.infoDictionary? ["CFBundleShortVersionString"] as? String
  return appVersion ?? "Unknown"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
