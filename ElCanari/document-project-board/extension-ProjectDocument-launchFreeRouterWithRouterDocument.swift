//
//  extension-ProjectDocument-launch.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension CustomizedProjectDocument {

  //····················································································································

  override func launchFreeRouterWithRouterDocument (_ sender : NSObject?) {
    let fm =  FileManager ()
  //---------- Get freerouter temporary directory
    let freerouterTemporaryBaseFilePath : String
    if let d = self.mFreerouterTemporaryBaseFilePath {
      freerouterTemporaryBaseFilePath = d
    }else{
      let h = Date ().hashValue
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
  //---------- Write gui_default.par

  //---------- Build freerouter document
    let exportTracks : Bool = self.rootObject.mExportExistingTracksAndVias
    let s = self.dsnContents (exportTracks)
  //---------- Write DSN file
    let dsnFilePath = freerouterTemporaryBaseFilePath + "design.dsn"
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

//----------------------------------------------------------------------------------------------------------------------
