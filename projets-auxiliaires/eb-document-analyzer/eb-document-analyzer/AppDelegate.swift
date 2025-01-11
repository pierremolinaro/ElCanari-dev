//
//  AppDelegate.swift
//  eb-document-analyzer
//
//  Created by Pierre Molinaro on 08/07/2015.
//  Copyright © 2015 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {

  //····················································································································

  @IBOutlet var mResultWindow : NSWindow?
  @IBOutlet var mResultTextView : NSTextView?

  //····················································································································

  @IBAction func openDocument (_: AnyObject?) {
    let op = NSOpenPanel ()
    op.allowsMultipleSelection = false
    op.canChooseDirectories = false
    op.canChooseFiles = true
    op.begin (completionHandler: { (inReturnCode : NSApplication.ModalResponse) in
      if inReturnCode == NSApplication.ModalResponse.OK {
        let URLToAdd : URL = op.urls [0]
        NSDocumentController.shared.noteNewRecentDocumentURL (URLToAdd)
        if let textView = self.mResultTextView {
          let pathToAdd = URLToAdd.path
          do{
            try analyze (pathToAdd, textView:textView)
          }catch let error as NSError {
            NSApp.presentError (error)
          }catch{
            print ("Unknown error")
          }
        }
      }
    })
  }

  //····················································································································

  func application (_ sender: NSApplication, openFile filename: String) -> Bool {

    if let textView = self.mResultTextView {
      do{
        try analyze (filename, textView:textView)
      }catch let error as NSError {
        NSApp.presentError (error)
      }catch{
        print ("Unknown error")
      }
    }
    return true
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
