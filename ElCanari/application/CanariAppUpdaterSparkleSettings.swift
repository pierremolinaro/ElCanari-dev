//
//  CanariAppUpdaterSettings.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/11/2015.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa
import Sparkle

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  http://sparkle-project.org/documentation/preferences-ui/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariAppUpdaterSettings) final class CanariAppUpdaterSettings : NSObject, EBUserClassNameProtocol {

  //····················································································································
  //   Outlets
  //····················································································································

  @IBOutlet private var mUpdateCheckbox : NSButton?
  @IBOutlet private var mCheckNowForUpdateButton : NSButton?
  @IBOutlet private var mUpdateIntervalPopUpButton : NSPopUpButton?
  @IBOutlet private var mSparkleVersionTextField : NSTextField?

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
    if let updater = Sparkle.SUUpdater.shared () {
      self.mCheckNowForUpdateButton?.target = updater
      self.mCheckNowForUpdateButton?.action = #selector (Sparkle.SUUpdater.checkForUpdates (_:))
      self.mUpdateCheckbox?.bind (
        NSBindingName.value,
        to: updater,
        withKeyPath: "automaticallyChecksForUpdates",
        options: nil
      )
      self.mUpdateIntervalPopUpButton?.bind (
        NSBindingName.selectedTag,
        to: updater,
        withKeyPath: "updateCheckInterval",
        options: nil
      )
      self.mUpdateIntervalPopUpButton?.bind (
        NSBindingName.enabled,
        to: updater,
        withKeyPath: "automaticallyChecksForUpdates",
        options: nil
      )
    //--- Now, we explore application bundle for finding sparkle version
      if let frameworkURL = Bundle.main.privateFrameworksURL {
        let infoPlistURL = frameworkURL.appendingPathComponent ("Sparkle.framework/Versions/Current/Resources/Info.plist")
        // print ("\(infoPlistURL)")
        do{
          let data : Data = try Data (contentsOf: infoPlistURL)
          // NSLog ("\(data)")
          if let plist = try PropertyListSerialization.propertyList (from:data, format:nil) as? NSDictionary {
            if let sparkleVersionString = plist ["CFBundleShortVersionString"] as? String {
              // NSLog ("\(sparkleVersionString)")
              self.mSparkleVersionTextField?.stringValue = "Using Sparkle " + sparkleVersionString
            }
          }
        }catch let error {
          NSLog ("Cannot read Sparkle plist: error \(error)")
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
