//
//  extension-ProjectDocument-launch.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2020.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func performLaunchFreeRouterWithRouterDocument () {
    if let mainWindow = self.windowForSheet {
      let fm = FileManager ()
    //---------- Install freeRouter application
      let optionalFreeRouterApplication = self.installFreeRouter (mainWindow)
    //---------- Get freerouter temporary directory
      if self.mFreerouterTemporaryDirectorySelection != preferences_mFreeRouterWorkingDirectorySelection_property.propval {
        self.mFreerouterTemporaryDirectory = nil
        self.mFreerouterTemporaryDirectorySelection = preferences_mFreeRouterWorkingDirectorySelection_property.propval
      }
      let freerouterTemporaryBaseFilePath : String
      if let d = self.mFreerouterTemporaryDirectory {
        freerouterTemporaryBaseFilePath = d
      }else{
        let df = DateFormatter()
        df.dateFormat = "yyyy'-'MM'-'dd'-'HH'h-'mm'min-'ss's"
        let baseName = df.string (from: Date ())
        if preferences_mFreeRouterWorkingDirectorySelection_property.propval == 0 {
          freerouterTemporaryBaseFilePath = NSTemporaryDirectory () + baseName + "/"
        }else{
          let documentAbsolutePath = NSHomeDirectory() + "/Documents"
          freerouterTemporaryBaseFilePath = documentAbsolutePath + "/freerouting/" + baseName + "/"
        }
        do {
          try fm.createDirectory (
            at: URL (fileURLWithPath: freerouterTemporaryBaseFilePath),
            withIntermediateDirectories: true,
            attributes: nil
          )
        }catch{
          let alert = NSAlert ()
          alert.messageText = "Cannot launch FreeRouting application"
          alert.informativeText = "Cannot create \"\(freerouterTemporaryBaseFilePath)\" directory"
          alert.beginSheetModal (for: mainWindow)
          return
        }
        self.mFreerouterTemporaryDirectory = freerouterTemporaryBaseFilePath
      }
    //---------- Write gui_default.par
      if preferences_mFreeRouterGuiDefaultFileContents_property.propval != "" {
        let guiDefaultPath = freerouterTemporaryBaseFilePath + "gui_defaults.par"
        try? preferences_mFreeRouterGuiDefaultFileContents_property.propval.write (to: URL (fileURLWithPath: guiDefaultPath), atomically: true, encoding: .utf8)
      }
    //---------- Build freerouter document
      let exportTracks : Bool = self.rootObject.mExportExistingTracksAndVias
      let s = self.dsnContents (exportTracks)
    //---------- Write DSN file
      let dsnFilePath = freerouterTemporaryBaseFilePath + "design.dsn"
      do{
        try s.write (to: URL (fileURLWithPath: dsnFilePath), atomically: true, encoding: .utf8)
      //--- Launch free router with document
        if let freeRouterApplication : URL = optionalFreeRouterApplication {
          let openConfiguration = NSWorkspace.OpenConfiguration ()
          openConfiguration.arguments = ["-de", dsnFilePath, "-oit", "0.0"]
          NSWorkspace.shared.openApplication (at: freeRouterApplication, configuration: openConfiguration)
        }
      }catch (_) {
        DispatchQueue.main.async {
          let alert = NSAlert ()
          alert.messageText = "Cannot launch FreeRouting application"
          alert.informativeText = "Cannot write \(dsnFilePath) file"
          alert.beginSheetModal (for: mainWindow)
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
