//
//  Preferences_SuperClass.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/01/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import Sparkle

//--------------------------------------------------------------------------------------------------

@MainActor class Preferences_SuperClass : NSObject {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Outlets
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBOutlet var mCheckNowForUpdateMenuItem : NSMenuItem? = nil
  @IBOutlet var mUpDateLibraryMenuItemInCanariMenu : NSMenuItem? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor override init () {
    super.init ()
    noteObjectAllocation (self)
    preferences_usesUserLibrary_property.mObserverCallback = { configureLibraryFileSystemObservation () }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func awakeFromNib () {
    DispatchQueue.main.async {
      self.mCheckNowForUpdateMenuItem?.target = self
      self.mCheckNowForUpdateMenuItem?.action = #selector (Self.checkForUpdatesAction (_:))
    }
    super.awakeFromNib ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func checkForUpdatesAction (_ inUnusedSender : Any?) {
    self.mUpdaterController.updater.checkForUpdates ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mDeviceCategorySet = Set <String> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var deviceCategorySet : Set <String> { self.mDeviceCategorySet }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setDeviceCategorySet (_ inDeviceCategorySet : Set <String>) {
    self.mDeviceCategorySet = inDeviceCategorySet
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Sparkle 2.x
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mUpdaterController = Sparkle.SPUStandardUpdaterController (updaterDelegate: nil, userDriverDelegate: nil)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var mLibraryUpdateLogWindow : CanariWindow? = nil
  final let mLibraryUpdateLogTextView =
    AutoLayoutStaticTextView (drawsBackground: false, horizontalScroller: true, verticalScroller: true)
        .expandableWidth ()
        .expandableHeight ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var mLibraryConsistencyLogWindow : CanariWindow? = nil
  final var mLibraryConsistencyLogTabView : AutoLayoutTabView? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setUpLibraryUpdateLogWindow () -> CanariWindow {
    if let window = self.mLibraryUpdateLogWindow {
      return window
    }else{
      let window = CanariWindow (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 400),
        styleMask: [.closable, .resizable, .titled],
        backing: .buffered,
        defer: false
      )
      self.mLibraryUpdateLogWindow = window
      _ = window.setFrameAutosaveName ("LibraryUpdateLogWindowSettings")
      window.title = "Library Update Log"
      window.isReleasedWhenClosed = false
      window.setContentView (self.mLibraryUpdateLogTextView)
      return window
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mCheckingForLibraryUpdateWindow : CanariWindow? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func showCheckingForLibraryUpdateWindow () {
    let window : CanariWindow
    if let w = self.mCheckingForLibraryUpdateWindow {
      window = w
    }else{
      window = CanariWindow (
        contentRect: NSRect (x: 0, y: 0, width: 250, height: 100),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
      self.mCheckingForLibraryUpdateWindow = window
      _ = window.setFrameAutosaveName ("CheckForLibraryUpdatesWindowSettings")
      window.title = "Checking for Library Updates…"
      window.isReleasedWhenClosed = false

      let hStack = AutoLayoutHorizontalStackView ()
        .appendFlexibleSpace ()
        .appendView (AutoLayoutSpinningProgressIndicator (size: .regular))
        .appendFlexibleSpace ()
      let contents = AutoLayoutVerticalStackView ()
        .appendFlexibleSpace ()
        .appendView (hStack)
        .appendFlexibleSpace ()

      window.setContentView (contents)
    }
    window.makeKeyAndOrderFront (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func hideCheckingForLibraryUpdateWindow () {
    self.mCheckingForLibraryUpdateWindow?.orderOut (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func showUpToDateAlertSheetForLibraryUpdateWindow () {
    if let window = self.mCheckingForLibraryUpdateWindow {
      let alert = NSAlert ()
      alert.messageText = "The library is up to date"
      alert.beginSheetModal (
        for: window,
        completionHandler: { (response : NSApplication.ModalResponse) in window.orderOut (nil) }
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
