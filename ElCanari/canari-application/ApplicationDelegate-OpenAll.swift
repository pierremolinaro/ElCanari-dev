//
//  ApplicationDelegate-OpenAll.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func actionOpenAllDocumentsInDirectory (_ inSender : AnyObject) {
    self.actionOpenAllDocumentInDirectory (["ElCanariSymbol", "ElCanariPackage", "ElCanariDevice"])
  }

  //····················································································································

  @IBAction func actionOpenAllSymbolsInDirectory (_ inSender : AnyObject) {
    self.actionOpenAllDocumentInDirectory (["ElCanariSymbol"])
  }

  //····················································································································

  @IBAction func actionOpenAllPackagesInDirectory (_ inSender : AnyObject) {
    self.actionOpenAllDocumentInDirectory (["ElCanariPackage"])
  }

  //····················································································································

  private func actionOpenAllDocumentInDirectory (_ extensions : Set <String>) {
    do{
      let op = NSOpenPanel ()
      op.allowsMultipleSelection = false
      op.canChooseDirectories = true
      op.canChooseFiles = false
      let response : NSApplication.ModalResponse = op.runModal ()
      if response == .OK {
        let baseDirectory : String = op.urls [0].path
        let fm = FileManager ()
        let dc = NSDocumentController ()
        let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
        var fileCount = 0
        for f in files {
          let fullpath = baseDirectory + "/" + f
          if extensions.contains (fullpath.pathExtension) {
            fileCount += 1
          }
        }
        if fileCount == 0 {
          let alert = NSAlert ()
          alert.messageText = "No document to Open"
          _ = alert.runModal ()
        }else{
          let alert = NSAlert ()
          alert.messageText = "Open \(fileCount) document\((fileCount > 1) ? "s" : "")?"
          alert.addButton (withTitle: "Ok")
          alert.addButton (withTitle: "Cancel")
          let response = alert.runModal ()
          if response == .alertFirstButtonReturn {
            for f in files {
              let fullpath = baseDirectory + "/" + f
              if extensions.contains (fullpath.pathExtension) {
                dc.openDocument (
                  withContentsOf: URL (fileURLWithPath: fullpath),
                  display: true,
                  completionHandler: { (document : NSDocument?, display : Bool, error : Error?) in
                    document?.windowForSheet?.makeKeyAndOrderFront (nil)
                    _ = RunLoop.main.run (mode: .default, before: Date ())
                  }
                )
              }
            }
          }
        }
      }
    }catch (let error) {
      let alert = NSAlert (error: error)
      _ = alert.runModal ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
