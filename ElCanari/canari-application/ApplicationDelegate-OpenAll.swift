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


  @IBAction func actionOpenAllSymbolsInDirectory (_ inSender : AnyObject) {
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
          if fullpath.pathExtension == "ElCanariSymbol" {
            dc.openDocument (
              withContentsOf: URL (fileURLWithPath: fullpath),
              display: true,
              completionHandler: { (document : NSDocument?, display : Bool, error : Error?) in }
            )
            RunLoop.main.run (mode: .default, before: Date (timeIntervalSinceNow: 0.1))
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
