//
//  extension-ProjectDocument-.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension CustomizedProjectDocument {

  //····················································································································

  override func importSESFromBasicTabAction (_ sender : NSObject?) {
    if let freerouterTemporaryBaseFilePath = self.mFreerouterTemporaryBaseFilePath {
      self.importSESFile (fileBasePath: freerouterTemporaryBaseFilePath)
    }else{
      let alert = NSAlert ()
      alert.messageText = "Cannot import SES file"
      alert.informativeText = "The SES file does not exist"
      alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
    }
  }

  //····················································································································

  fileprivate func importSESFile (fileBasePath inFileBasePath : String) {
    let filePath = inFileBasePath + "design.ses"
    do{
      let sesContents = try String (contentsOf: URL (fileURLWithPath: filePath), encoding: .utf8)
      if let panel = self.mImportSESPanel,
         let textField = self.mImportSESTextField,
         let progressIndicator = self.mImportSESProgressIndicator {
        self.handleSESFileContents (sesContents, panel, textField, progressIndicator)
      }else{
        let alert = NSAlert ()
        alert.messageText = "Cannot import SES file"
        alert.informativeText = "Internal error"
        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
      }
    }catch (_) {
      let alert = NSAlert ()
      alert.messageText = "Cannot import SES file"
      alert.informativeText = "The \(filePath) file does not exist"
      alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
