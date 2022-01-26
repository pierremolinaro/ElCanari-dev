//
//  CanariAppUpdaterSettings.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/11/2015.
//  Utilisation de Sparkle sous le Swift Package Manager, 20 novembre 2021
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa
import Sparkle

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

var gCanariAppUpdaterSettings : CanariAppUpdaterSettings? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  http://sparkle-project.org/documentation/preferences-ui/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariAppUpdaterSettings) final class CanariAppUpdaterSettings : NSObject {

  //····················································································································
  //   Outlets
  //····················································································································

//  @IBOutlet private var mUpdateCheckbox : NSButton?
//  @IBOutlet private var mUpdateIntervalPopUpButton : NSPopUpButton?
//  @IBOutlet private var mSparkleVersionTextField : NSTextField?
//  @IBOutlet private var mCheckNowForUpdateButton : NSButton?
//  @IBOutlet private var mCheckNowForUpdateMenuItem : NSMenuItem?

  //····················································································································

  override init () {
    super.init ()
    gCanariAppUpdaterSettings = self
  }
  
  //····················································································································
  // Sparkle 2.x
  //····················································································································

  private let mUpdaterController = Sparkle.SPUStandardUpdaterController (updaterDelegate: nil, userDriverDelegate: nil)
//  private var mSparkleVersionString = "?"

  //····················································································································

//  override func awakeFromNib () {
//    let updater = self.mUpdaterController.updater
//    self.mCheckNowForUpdateButton?.target = self
//    self.mCheckNowForUpdateButton?.action = #selector (Self.checkForUpdatesAction (_:))
//    self.mCheckNowForUpdateMenuItem?.target = self
//    self.mCheckNowForUpdateMenuItem?.action = #selector (Self.checkForUpdatesAction (_:))
//    self.mUpdateCheckbox?.bind (
//      NSBindingName.value,
//      to: updater,
//      withKeyPath: "automaticallyChecksForUpdates",
//      options: nil
//    )
//    self.mUpdateIntervalPopUpButton?.bind (
//      NSBindingName.selectedTag,
//      to: updater,
//      withKeyPath: "updateCheckInterval",
//      options: nil
//    )
//    self.mUpdateIntervalPopUpButton?.bind (
//      NSBindingName.enabled,
//      to: updater,
//      withKeyPath: "automaticallyChecksForUpdates",
//      options: nil
//    )
//  //--- Now, we explore application bundle for finding sparkle version
//    if let frameworkURL = Bundle.main.privateFrameworksURL {
//      let infoPlistURL = frameworkURL.appendingPathComponent ("Sparkle.framework/Versions/Current/Resources/Info.plist")
//      // print ("\(infoPlistURL)")
//      do{
//        let data : Data = try Data (contentsOf: infoPlistURL)
//        // NSLog ("\(data)")
//        if let plist = try PropertyListSerialization.propertyList (from:data, format:nil) as? NSDictionary {
//          if let sparkleVersionString = plist ["CFBundleShortVersionString"] as? String {
//            // NSLog ("\(sparkleVersionString)")
//       //     self.mSparkleVersionTextField?.stringValue = "Using Sparkle " + sparkleVersionString
//            self.mSparkleVersionString = sparkleVersionString
//          }
//        }
//      }catch let error {
//        NSLog ("Cannot read Sparkle plist: error \(error)")
//      }
//    }
//  }

  //····················································································································

  func checkForUpdatesAction () {
    self.mUpdaterController.updater.checkForUpdates ()
  }

  //····················································································································

  func sparkleVersionString () -> String {
    var result = "?"
    if let frameworkURL = Bundle.main.privateFrameworksURL {
      let infoPlistURL = frameworkURL.appendingPathComponent ("Sparkle.framework/Versions/Current/Resources/Info.plist")
      if let data : Data = try? Data (contentsOf: infoPlistURL),
         let plist = try? PropertyListSerialization.propertyList (from: data, format: nil) as? NSDictionary,
         let sparkleVersionString = plist ["CFBundleShortVersionString"] as? String {
            result = sparkleVersionString
      }
    }
    return result
  }

  //····················································································································

  func configureAutomaticallyCheckForUpdatesButton (_ inOutlet : NSButton) {
    inOutlet.bind (
      NSBindingName.value,
      to: self.mUpdaterController.updater,
      withKeyPath: "automaticallyChecksForUpdates",
      options: nil
    )
  }

 //····················································································································

  func configureCheckIntervalPopUpButton (_ inOutlet : NSPopUpButton) {
    let updater = self.mUpdaterController.updater
    inOutlet.bind (
      NSBindingName.selectedTag,
      to: updater,
      withKeyPath: "updateCheckInterval",
      options: nil
    )
    inOutlet.bind (
      NSBindingName.enabled,
      to: updater,
      withKeyPath: "automaticallyChecksForUpdates",
      options: nil
    )
  }

 //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
