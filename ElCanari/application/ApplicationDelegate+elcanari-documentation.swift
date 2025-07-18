//
//  ApplicationDelegate-elcanari-documentation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gWindow : NSWindow? = nil

//--------------------------------------------------------------------------------------------------

extension ApplicationDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   OPEN ELCANARI DOCUMENTATION
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBAction func openElCanariDocumentationAction (_ inSender : Any?) {
    if gWindow == nil {
      let docPath = systemLibraryPath () + "/pdf/ElCanari-user-manual.pdf"
      if let data = FileManager ().contents (atPath: docPath) {
        gWindow = CanariPDFWindow (fileName: docPath.lastPathComponent, pdfData: data)
      }
    }
    gWindow?.makeKeyAndOrderFront (inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   OPEN LIBRARY STATUS WINDOW
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBAction func openLibraryStatusWindowAction (_ inSender : Any?) {
    self.mLibraryStatusLogWindow?.makeKeyAndOrderFront (inSender)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

