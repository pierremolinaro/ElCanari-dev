//
//  extension-ProjectDocument-.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2020.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func importGuiDefaultFileThenSESFile (fileBasePath inFileBasePath : String) {
    let filePath = inFileBasePath + "gui_defaults.par"
    if let fileContents = try? String (contentsOf: URL (fileURLWithPath: filePath), encoding: .utf8), preferences_mFreeRouterGuiDefaultFileContents_property.propval != fileContents {
      let alert = NSAlert ()
      _ = alert.addButton (withTitle: "Import")
      _ = alert.addButton (withTitle: "Do not Import")
      alert.messageText = "FreeRouter gui defaults file did change."
      alert.informativeText = "Import new contents into ElCanari preferences ?"
      alert.beginSheetModal (for: self.windowForSheet!) { (inResponse : NSApplication.ModalResponse) in
        DispatchQueue.main.async {
          if inResponse == .alertFirstButtonReturn {
            preferences_mFreeRouterGuiDefaultFileContents_property.setProp (fileContents)
          }
          self.importSESFile (fileBasePath: inFileBasePath)
        }
      }
    }else{
      self.importSESFile (fileBasePath: inFileBasePath)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func importSESFile (fileBasePath inFileBasePath : String) {
    let filePath = inFileBasePath + "design.ses"
    do{
      let sesContents = try String (contentsOf: URL (fileURLWithPath: filePath), encoding: .utf8)
      self.handleSESFileContents (sesContents)
    }catch (_) {
      let alert = NSAlert ()
      alert.messageText = "Cannot import SES file"
      alert.informativeText = "The \(filePath) file does not exist"
      alert.beginSheetModal (for: self.windowForSheet!)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
