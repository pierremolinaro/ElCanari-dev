//
//  extension-ProjectDocument-launch.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2020.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocumentSubClass {

  //····················································································································

  override func launchFreeRouterWithRouterDocument (_ sender : NSObject?) {
    self.checkSchematicsAndBeforeAndLaunchFreeRouteur { self.performLaunchFreeRouterWithRouterDocument () }
  }

  //····················································································································

  func performLaunchFreeRouterWithRouterDocument () {
    let fm =  FileManager ()
  //---------- Get freerouter temporary directory
    let freerouterTemporaryBaseFilePath : String
    if let d = self.mFreerouterTemporaryBaseFilePath {
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
        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
        return
      }
      self.mFreerouterTemporaryBaseFilePath = freerouterTemporaryBaseFilePath
    }
    // Swift.print ("freerouterTemporaryBaseFilePath \(freerouterTemporaryBaseFilePath)")
  //---------- Write gui_default.par
    if preferences_mFreeRouterGuiDefaultFileContents != "" {
      let guiDefaultPath = freerouterTemporaryBaseFilePath + "gui_defaults.par"
      try? preferences_mFreeRouterGuiDefaultFileContents.write (to: URL (fileURLWithPath: guiDefaultPath), atomically: true, encoding: .utf8)
      // Swift.print ("WRITE PATH \(guiDefaultPath)")
    }
  //---------- Build freerouter document
    let exportTracks : Bool = self.rootObject.mExportExistingTracksAndVias
    let s = self.dsnContents (exportTracks)
  //---------- Write DSN file
    let dsnFilePath = freerouterTemporaryBaseFilePath + "design.dsn"
    // Swift.print ("freerouterTemporaryBaseFilePath \(freerouterTemporaryBaseFilePath)")
    do{
      try s.write (to: URL (fileURLWithPath: dsnFilePath), atomically: true, encoding: .utf8)
    //--- Launch free router with document
      if let freeRouterApplication : URL = Bundle.main.url (forResource: "Freerouting", withExtension: "app") {
        let arguments = ["-de", dsnFilePath]
        if let _ = try? NSWorkspace.shared.launchApplication (at: freeRouterApplication, configuration: [.arguments : arguments]) {
        }else{
          let alert = NSAlert ()
          alert.messageText = "Cannot launch FreeRouting application"
          alert.informativeText = "FreeRouting application does not exist."
          alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
        }
      }
    }catch (_) {
      let alert = NSAlert ()
      alert.messageText = "Cannot launch FreeRouting application"
      alert.informativeText = "Cannot write \(dsnFilePath) file"
      alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
