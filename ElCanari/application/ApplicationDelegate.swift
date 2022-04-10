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
  //--- Build Batch Window
    self.mBatchWindow = NSWindow (
      contentRect: NSRect (x: 0, y: 0, width: 600, height: 400),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: false
    )
    self.mBatchWindow.title = "Batch Operations"
    self.mBatchWindow.hasShadow = true
  //--- Main view
    let mainView = AutoLayoutHorizontalStackView ().set (margins: 20)
  //--- First Column
    let firstColumn = AutoLayoutVerticalStackView ()
    firstColumn.appendView (AutoLayoutStaticLabel (title: "Open All…", bold: true, size: .regular).set (alignment: .left))
    let openAllSymbolsInDirectory = AutoLayoutButton (title: "Symbols in directory…", size: .regular)
    firstColumn.appendView (openAllSymbolsInDirectory)
    let openAllPackagesInDirectory = AutoLayoutButton (title: "Packages in directory…", size: .regular)
    firstColumn.appendView (openAllPackagesInDirectory)
    let openAllDevicesInDirectory = AutoLayoutButton (title: "Devices in directory…", size: .regular)
    firstColumn.appendView (openAllDevicesInDirectory)
    let openAllFontsInDirectory = AutoLayoutButton (title: "Fonts in directory…", size: .regular)
    firstColumn.appendView (openAllFontsInDirectory)
//    let openAllProjectsInDirectory = AutoLayoutButton (title: "Projects in directory…", size: .regular)
//    firstColumn.appendView (openAllProjectsInDirectory)
    let openAllDocumentsInDirectory = AutoLayoutButton (title: "Documents in directory…", size: .regular)
    firstColumn.appendView (openAllDocumentsInDirectory)
    firstColumn.appendView (AutoLayoutStaticLabel (title: "Update All…", bold: true, size: .regular).set (alignment: .left))
    let updateAllDevicesInDirectory = AutoLayoutButton (title: "Devices in directory…", size: .regular)
    firstColumn.appendView (updateAllDevicesInDirectory)
    let updateAllProjectsInDirectory = AutoLayoutButton (title: "Projects in directory…", size: .regular)
    firstColumn.appendView (updateAllProjectsInDirectory)
    firstColumn.appendView (AutoLayoutStaticLabel (title: "Convert to Textual Format…", bold: true, size: .regular).set (alignment: .left))
    let convertToTextualDocumentsInDirectory = AutoLayoutButton (title: "Documents in directory…", size: .regular)
    firstColumn.appendView (convertToTextualDocumentsInDirectory)
    firstColumn.appendView (AutoLayoutStaticLabel (title: "Convert to Binary Format…", bold: true, size: .regular).set (alignment: .left))
    let convertToBinaryDocumentsInDirectory = AutoLayoutButton (title: "Documents in directory…", size: .regular)
    firstColumn.appendView (convertToBinaryDocumentsInDirectory)
    mainView.appendView (firstColumn)
  //--- Second Column
    let secondColumn = AutoLayoutVerticalStackView ()
    let logTitleLabel = AutoLayoutStaticLabel (title: "Log", bold: true, size: .regular).set (alignment: .center).expandableWidth ()
    secondColumn.appendView (logTitleLabel)
    self.mMaintenanceLogTextView = AutoLayoutStaticTextView (drawsBackground: true, horizontalScroller: false, verticalScroller: true)
    secondColumn.appendView (self.mMaintenanceLogTextView)
    self.mMaintenanceLogTextField = AutoLayoutLabel (bold: false, size: .regular).set (alignment: .left).expandableWidth ()
    secondColumn.appendView (self.mMaintenanceLogTextField)
    mainView.appendView (secondColumn)
  //--- Set autolayout view to window
    self.mBatchWindow.contentView = AutoLayoutWindowContentView (view: mainView)
  //---
    super.init ()
    gApplicationDelegate = self
  //---
    _ = openAllSymbolsInDirectory.bind_run (target: self, selector: #selector (Self.actionOpenAllSymbolsInDirectory (_:)))
    _ = openAllPackagesInDirectory.bind_run (target: self, selector: #selector (Self.actionOpenAllPackagesInDirectory (_:)))
    _ = openAllDevicesInDirectory.bind_run (target: self, selector: #selector (Self.actionOpenAllDevicesInDirectory (_:)))
    _ = openAllFontsInDirectory.bind_run (target: self, selector: #selector (Self.actionOpenAllFontsInDirectory (_:)))
    _ = openAllDocumentsInDirectory.bind_run (target: self, selector: #selector (Self.actionOpenAllDocumentsInDirectory (_:)))
    _ = updateAllDevicesInDirectory.bind_run (target: self, selector: #selector (Self.updateAllDevicesInDirectory (_:)))
    _ = updateAllProjectsInDirectory.bind_run (target: self, selector: #selector (Self.updateAllProjectsInDirectory (_:)))
    _ = convertToTextualDocumentsInDirectory.bind_run (target: self, selector: #selector (Self.actionConvertToTextualFormatAllDocumentsInDirectory (_:)))
    _ = convertToBinaryDocumentsInDirectory.bind_run (target: self, selector: #selector (Self.actionConvertToBinaryFormatAllDocumentsInDirectory (_:)))
  }

  //····················································································································
  //  Outlets
  //····················································································································

  @IBOutlet var mCheckNowForUpdateMenuItem : NSMenuItem? = nil
  @IBOutlet var mUpDateLibraryMenuItemInCanariMenu : NSMenuItem? = nil

  //····················································································································
  //  Batch Window
  //····················································································································

  let mBatchWindow : NSWindow
  let mMaintenanceLogTextView : AutoLayoutStaticTextView
  let mMaintenanceLogTextField : AutoLayoutLabel

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
    // self.mMaintenanceLogTextField.stringValue = ""
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
    }else if action == #selector (Self.showBatchWindow (_:)) {
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
