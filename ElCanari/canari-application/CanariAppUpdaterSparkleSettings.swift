//
//  CanariAppUpdaterSettings.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  http://sparkle-project.org/documentation/preferences-ui/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariAppUpdaterSettings) class CanariAppUpdaterSettings : NSObject, EBUserClassNameProtocol {
  @IBOutlet private var mUpdateCheckbox : NSButton?
  @IBOutlet private var mUpdateIntervalPopUpButton : NSPopUpButton?

  @IBOutlet private var mSparkleUpdater : NSObject?

  //····················································································································

  override init () {
    super.init ()
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func awakeFromNib () {
    if let updater = mSparkleUpdater {
      mUpdateCheckbox?.bind (
        "value",
        to:updater,
        withKeyPath: "automaticallyChecksForUpdates",
        options: nil
      )
      mUpdateIntervalPopUpButton?.bind (
        "selectedTag",
        to:updater,
        withKeyPath: "updateCheckInterval",
        options: nil
      )
      mUpdateIntervalPopUpButton?.bind (
        "enabled",
        to:updater,
        withKeyPath: "automaticallyChecksForUpdates",
        options: nil
      )
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
