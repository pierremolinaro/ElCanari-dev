//
//  ApplicationDelegate-elcanari-documentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate var gWindow : NSWindow? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································
  //   OPEN ELCANARI DOCUMENTATION
  //····················································································································

  @IBAction func openElCanariDocumentationAction (_ inSender : Any?) {
    if gWindow == nil,
       let docPath = Bundle.main.path (forResource: "ElCanari-user-manual", ofType: "pdf"),
       let data = FileManager ().contents (atPath: docPath) {
      gWindow = CanariPDFWindow (fileName: docPath.lastPathComponent, pdfData: data)
    }
    gWindow?.makeKeyAndOrderFront (nil)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

