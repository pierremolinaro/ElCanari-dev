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
    self.actionOpenAllDocumentInDirectory (["ElCanariSymbol", "ElCanariPackage"])
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
    let op = NSOpenPanel ()
    op.allowsMultipleSelection = false
    op.canChooseDirectories = true
    op.canChooseFiles = false
    let response : NSApplication.ModalResponse = op.runModal ()
    if response == .OK {
      let baseDirectory : String = op.urls [0].path
      let fm = FileManager ()
      let dc = NSDocumentController ()
      do{
        let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
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
      }catch (let error) {
        let alert = NSAlert (error: error)
        _ = alert.runModal ()
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
