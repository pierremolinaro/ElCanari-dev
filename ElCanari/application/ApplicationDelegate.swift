//
//  ApplicationDelegate.swift
//  canari
//
//  Created by Pierre Molinaro on 03/07/2015.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let ElCanariSymbol_EXTENSION  = "elcanarisymbol"
let ElCanariPackage_EXTENSION = "elcanaripackage"
let ElCanariDevice_EXTENSION  = "elcanaridevice"
let ElCanariFont_EXTENSION    = "elcanarifont"
let ElCanariArtwork_EXTENSION = "elcanariartwork"
let ElCanariProject_EXTENSION = "elcanariproject"
let ElCanariMerger_EXTENSION  = "elcanarimerger"

//--------------------------------------------------------------------------------------------------

let ALL_ELCANARI_DOCUMENT_EXTENSIONS = Set ([
  ElCanariSymbol_EXTENSION,
  ElCanariPackage_EXTENSION,
  ElCanariDevice_EXTENSION,
  ElCanariFont_EXTENSION,
  ElCanariArtwork_EXTENSION,
  ElCanariProject_EXTENSION,
  ElCanariMerger_EXTENSION
])

//--------------------------------------------------------------------------------------------------

@MainActor @main final class ApplicationDelegate : Preferences, NSApplicationDelegate, NSMenuItemValidation, Sendable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Batch Window
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mBatchWindow : NSWindow? = nil
  var mMaintenanceLogTextView : AutoLayoutStaticTextView? = nil
  var mMaintenanceLogTextField : AutoLayoutLabel? = nil

  var mCount = 0
  var mHandledFiles = [String] ()
  var mTotalFileCount = 0
  var mHandledFileCount = 0
  var mStartDate = Date ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Instanciate Batch Window
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func instanciatedBatchWindow () {
    if self.mBatchWindow == nil {
      let batchWindow = NSWindow (
        contentRect: NSRect (x: 0, y: 0, width: 600, height: 400),
        styleMask: [.titled, .resizable, .closable],
        backing: .buffered,
        defer: false
      )
      batchWindow.isReleasedWhenClosed = false // Close button just hides the window, but do not release it
      batchWindow.title = "Batch Operations"
      batchWindow.setFrameAutosaveName ("BatchWindowFrame")
      batchWindow.hasShadow = true
    //--- Main view
      let mainView = AutoLayoutHorizontalStackView ().set (margins: .large)
    //--- First Column
      let firstColumn = AutoLayoutVerticalStackView ()
      _ = firstColumn.appendView (AutoLayoutStaticLabel (title: "Open All…", bold: true, size: .regular, alignment: .left))
      let openAllSymbolsInDirectory = AutoLayoutButton (title: "Symbols in directory…", size: .regular)
      _ = firstColumn.appendView (openAllSymbolsInDirectory)
      let openAllPackagesInDirectory = AutoLayoutButton (title: "Packages in directory…", size: .regular)
      _ = firstColumn.appendView (openAllPackagesInDirectory)
      let openAllDevicesInDirectory = AutoLayoutButton (title: "Devices in directory…", size: .regular)
      _ = firstColumn.appendView (openAllDevicesInDirectory)
      let openAllFontsInDirectory = AutoLayoutButton (title: "Fonts in directory…", size: .regular)
      _ = firstColumn.appendView (openAllFontsInDirectory)
  //    let openAllProjectsInDirectory = AutoLayoutButton (title: "Projects in directory…", size: .regular)
  //    firstColumn.appendView (openAllProjectsInDirectory)
      let openAllDocumentsInDirectory = AutoLayoutButton (title: "Documents in directory…", size: .regular)
      _ = firstColumn.appendView (openAllDocumentsInDirectory)
      _ = firstColumn.appendView (AutoLayoutStaticLabel (title: "Update All…", bold: true, size: .regular, alignment: .left))
      let updateAllDevicesInDirectory = AutoLayoutButton (title: "Devices in directory…", size: .regular)
      _ = firstColumn.appendView (updateAllDevicesInDirectory)
      let updateAllProjectsInDirectory = AutoLayoutButton (title: "Projects in directory…", size: .regular)
      _ = firstColumn.appendView (updateAllProjectsInDirectory)
      _ = firstColumn.appendView (AutoLayoutStaticLabel (title: "Convert to Textual Format…", bold: true, size: .regular, alignment: .left))
      let convertToTextualDocumentsInDirectory = AutoLayoutButton (title: "Documents in directory…", size: .regular)
      _ = firstColumn.appendView (convertToTextualDocumentsInDirectory)
      _ = firstColumn.appendView (AutoLayoutStaticLabel (title: "Convert to Binary Format…", bold: true, size: .regular, alignment: .left))
      let convertToBinaryDocumentsInDirectory = AutoLayoutButton (title: "Documents in directory…", size: .regular)
      _ = firstColumn.appendView (convertToBinaryDocumentsInDirectory)
      _ = mainView.appendView (firstColumn)
    //--- Second Column
      let secondColumn = AutoLayoutVerticalStackView ()
      let logTitleLabel = AutoLayoutStaticLabel (title: "Log", bold: true, size: .regular, alignment: .center)
      _ = secondColumn.appendView (logTitleLabel)
      let maintenanceLogTextView = AutoLayoutStaticTextView (drawsBackground: true, horizontalScroller: false, verticalScroller: true)
      _ = secondColumn.appendView (maintenanceLogTextView)
      self.mMaintenanceLogTextView = maintenanceLogTextView
      let maintenanceLogTextField = AutoLayoutLabel (bold: false, size: .regular).set (alignment: .left).expandableWidth ()
      _ = secondColumn.appendView (maintenanceLogTextField)
      self.mMaintenanceLogTextField = maintenanceLogTextField
      _ = mainView.appendView (secondColumn)
    //--- Set autolayout view to window
      batchWindow.setContentView (mainView)
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
    //---
      self.mBatchWindow = batchWindow
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Open xxx in library
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBOutlet var mOpenSymbolInLibraryMenuItem : NSMenuItem? = nil
  @IBOutlet var mOpenPackageInLibraryMenuItem : NSMenuItem? = nil
  @IBOutlet var mOpenDeviceInLibraryMenuItem : NSMenuItem? = nil
  @IBOutlet var mOpenFontInLibraryMenuItem : NSMenuItem? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  DO NOT OPEN A NEW DOCUMENT ON LAUNCH
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  nonisolated func applicationShouldOpenUntitledFile (_ inApplication : NSApplication) -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func applicationWillFinishLaunching (_ inNotification : Notification) {
    self.mOpenSymbolInLibraryMenuItem?.target = gOpenSymbolInLibrary
    self.mOpenSymbolInLibraryMenuItem?.action = #selector (OpenSymbolInLibrary.openSymbolInLibrary (_:))
    self.mOpenPackageInLibraryMenuItem?.target = gOpenPackageInLibrary
    self.mOpenPackageInLibraryMenuItem?.action = #selector (OpenPackageInLibrary.openPackageInLibrary (_:))
    self.mOpenDeviceInLibraryMenuItem?.target = gOpenDeviceInLibrary
    self.mOpenDeviceInLibraryMenuItem?.action = #selector (OpenDeviceInLibrary.openDeviceInLibrary (_:))
    self.mOpenFontInLibraryMenuItem?.target = gOpenFontInLibrary
    self.mOpenFontInLibraryMenuItem?.action = #selector (OpenFontInLibrary.openFontInLibrary (_:))
  //---
    self.checkForLibraryUpdateAtLaunch ()
    instanciateDebugMenuObjectOnWillFinishLaunchingNotification ()
    // self.createDemosWindows ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SAVE ALL ACTION
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBAction func saveAllAction (_ inSender : Any?) {
    for document in NSDocumentController.shared.documents {
      document.save (inSender)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Menu Events
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  nonisolated func validateMenuItem (_ inMenuItem : NSMenuItem) -> Bool {
    let validate : Bool
    let action = inMenuItem.action
    if action == #selector (Self.actionNewProjectDocument (_:)) {
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
    }else if action == #selector (Self.openElCanariDocumentationAction (_:)) {
      validate = true
    }else if action == #selector (Self.openLibraryStatusWindowAction (_:)) {
      validate = true
    }else{
      validate = false
    }
    return validate
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Ajout 13 avril 2025, suite au warning de Xcode :
  // WARNING: Secure coding is automatically enabled for restorable state!
  //  However, not on all supported macOS versions of this application.
  //  Opt-in to secure coding explicitly by implementing
  //  NSApplicationDelegate.applicationSupportsSecureRestorableState:.
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func applicationSupportsSecureRestorableState (_ application : NSApplication) -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
}

//--------------------------------------------------------------------------------------------------
//  ELCANARI VERSION
//--------------------------------------------------------------------------------------------------

func ElCanariApplicationVersionString () -> String {
  let appVersion = Bundle.main.infoDictionary? ["CFBundleShortVersionString"] as? String
  return appVersion ?? "Unknown"
}

//--------------------------------------------------------------------------------------------------
