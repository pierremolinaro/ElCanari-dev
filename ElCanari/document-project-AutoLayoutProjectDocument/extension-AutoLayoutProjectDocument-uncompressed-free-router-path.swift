//
//  extension-AutoLayoutProjectDocument-uncompress-free-router.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  func uncompressedFreeRouterURL () -> URL? {
    if let directory = self.mFreerouterTemporaryApplicationDirectory {
      return URL (fileURLWithPath: directory + "/Freerouting.app")
    }else{
      let fm = FileManager ()
      let archivePath = systemLibraryPath () + "/freerouter/Freerouting.app.tar.xz"
    //--- Create temporary directory
      let h = UInt (bitPattern: Date ().hashValue)
      let freerouterTemporaryBaseFilePath = NSTemporaryDirectory () + "\(h)/"
      // Swift.print ("TEMP \(freerouterTemporaryBaseFilePath)")
      do {
        try fm.createDirectory (at: URL (fileURLWithPath: freerouterTemporaryBaseFilePath), withIntermediateDirectories: false, attributes: nil)
      }catch (_) {
        let alert = NSAlert ()
        alert.messageText = "Cannot launch FreeRouting application"
        alert.informativeText = "Cannot create \"\(freerouterTemporaryBaseFilePath)\" directory"
        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
        return nil
      }
   //--- Uncompress freerouter archive
      let task = Process ()
      task.launchPath = "/usr/bin/tar"
      task.arguments = ["-xJf", archivePath]
      task.currentDirectoryURL = URL (fileURLWithPath: freerouterTemporaryBaseFilePath)
      task.launch ()
      task.waitUntilExit ()
      let status = task.terminationStatus
      // Swift.print ("STATUS \(status)")
      if status == 0 {
        self.mFreerouterTemporaryApplicationDirectory = freerouterTemporaryBaseFilePath
        return URL (fileURLWithPath: freerouterTemporaryBaseFilePath + "/Freerouting.app")
      }else{
        let alert = NSAlert ()
        alert.messageText = "Cannot launch FreeRouting application"
        alert.informativeText = "Application uncompression returns \"\(status)\" status"
        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
        return nil
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
