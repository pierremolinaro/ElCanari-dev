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

  func performLaunchFreeRouterWithRouterDocument () {
    if let mainWindow = self.windowForSheet {
      let fm = FileManager ()
    //---------- Install freeRouter application
      let optionalFreeRouterApplication = self.installFreeRouter (mainWindow)
    //---------- Get freerouter temporary directory
      let freerouterTemporaryBaseFilePath : String
      if let d = self.mFreerouterTemporaryDocumentDirectory {
        freerouterTemporaryBaseFilePath = d
      }else{
        let h = UInt (bitPattern: Date ().hashValue)
        freerouterTemporaryBaseFilePath = NSTemporaryDirectory () + "\(h)/"
        do {
          try fm.createDirectory (at: URL (fileURLWithPath: freerouterTemporaryBaseFilePath), withIntermediateDirectories: false, attributes: nil)
        }catch (_) {
          let alert = NSAlert ()
          alert.messageText = "Cannot launch FreeRouting application"
          alert.informativeText = "Cannot create \"\(freerouterTemporaryBaseFilePath)\" directory"
          alert.beginSheetModal (for: mainWindow)
          return
        }
        self.mFreerouterTemporaryDocumentDirectory = freerouterTemporaryBaseFilePath
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
          NSWorkspace.shared.openApplication (at: freeRouterApplication, configuration: openConfiguration) // (Crash on 15.3) { (_, _) in }
        // Completion handler --> crash on 15.3
//          NSWorkspace.shared.openApplication (at: freeRouterApplication, configuration: openConfiguration) { (_, optionalError) in
//            if optionalError != nil {
//              DispatchQueue.main.async {
//                let alert = NSAlert ()
//                alert.messageText = "Cannot launch FreeRouting application"
//                alert.informativeText = "FreeRouting application does not exist."
//                alert.beginSheetModal (for: mainWindow)
//              }
//            }
//          }
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
