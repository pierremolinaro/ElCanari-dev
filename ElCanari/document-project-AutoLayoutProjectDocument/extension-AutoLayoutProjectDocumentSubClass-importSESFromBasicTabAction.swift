//
//  extension-ProjectDocument-.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2020.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocumentSubClass {

  //····················································································································

  override func importSESFromBasicTabAction (_ sender : NSObject?) {
    if let freerouterTemporaryBaseFilePath = self.mFreerouterTemporaryBaseFilePath {
      self.importGuiDefaultFile (fileBasePath: freerouterTemporaryBaseFilePath)
    }else{
      let alert = NSAlert ()
      alert.messageText = "Cannot import SES file"
      alert.informativeText = "The SES file does not exist"
      alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
    }
  }

  //····················································································································

  fileprivate func importGuiDefaultFile (fileBasePath inFileBasePath : String) {
    let filePath = inFileBasePath + "gui_defaults.par"
    if let fileContents = try? String (contentsOf: URL (fileURLWithPath: filePath), encoding: .utf8), preferences_mFreeRouterGuiDefaultFileContents != fileContents {
      let alert = NSAlert ()
      alert.addButton (withTitle: "Import")
      alert.addButton (withTitle: "Do not Import")
      alert.messageText = "FreeRouter gui defaults file did change."
      alert.informativeText = "Import new contents into ElCanari preferences ?"
      alert.beginSheetModal (for: self.windowForSheet!) { (inResponse : NSApplication.ModalResponse) in
        if inResponse == .alertFirstButtonReturn {
          preferences_mFreeRouterGuiDefaultFileContents = fileContents
          // Swift.print ("WRITE PREFS")
        }
        DispatchQueue.main.async { self.importSESFile (fileBasePath: inFileBasePath) }
      }
    }else{
      self.importSESFile (fileBasePath: inFileBasePath)
    }
  }

  //····················································································································

  fileprivate func importSESFile (fileBasePath inFileBasePath : String) {
    let filePath = inFileBasePath + "design.ses"
    do{
      let sesContents = try String (contentsOf: URL (fileURLWithPath: filePath), encoding: .utf8)
      self.handleSESFileContents (sesContents)
    }catch (_) {
      let alert = NSAlert ()
      alert.messageText = "Cannot import SES file"
      alert.informativeText = "The \(filePath) file does not exist"
      alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
