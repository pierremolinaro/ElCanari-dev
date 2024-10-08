//
//  ApplicationDelegate-app-update.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/03/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension Preferences_SuperClass {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func sparkleVersionString () -> String {
    var result = "?"
    if let frameworkURL = Bundle.main.privateFrameworksURL {
      let infoPlistURL = frameworkURL.appendingPathComponent ("Sparkle.framework/Versions/Current/Resources/Info.plist")
      if let data : Data = try? Data (contentsOf: infoPlistURL),
         let plist = try? PropertyListSerialization.propertyList (from: data, format: nil) as? [String : Any],
         let sparkleVersionString = plist ["CFBundleShortVersionString"] as? String {
            result = sparkleVersionString
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func configureAutomaticallyCheckForUpdatesButton (_ inOutlet : NSButton) {
    inOutlet.bind (
      NSBindingName.value,
      to: self.mUpdaterController.updater,
      withKeyPath: "automaticallyChecksForUpdates",
      options: nil
    )
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
