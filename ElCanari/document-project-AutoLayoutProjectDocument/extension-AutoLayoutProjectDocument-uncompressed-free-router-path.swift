//
//  extension-AutoLayoutProjectDocument-uncompress-free-router.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

let FREEROUTING_DIR = NSHomeDirectory () + "/Library/Application Support/FreeRouterForElCanari"
let FREEROUTING_APPLICATION_PATH = FREEROUTING_DIR + "/Freerouting.app"
let FREEROUTING_ARCHIVE_PATH = systemLibraryPath () + "/freerouter/Freerouting.app.tar.xz"
let RELEASE_FILE_PATH = FREEROUTING_DIR + "/release.txt"

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  func installFreeRouter (_ inMainWindow : NSWindow) -> URL? {
    let fm = FileManager ()
  //------------- Create directory
    var ok = true
    if !fm.fileExists (atPath: FREEROUTING_DIR) {
      do {
        try fm.createDirectory (at: URL (fileURLWithPath: FREEROUTING_DIR), withIntermediateDirectories: false, attributes: nil)
      }catch _ {
        let alert = NSAlert ()
        alert.messageText = "Cannot install FreeRouting application"
        alert.informativeText = "Cannot create \"\(FREEROUTING_DIR)\" directory"
        alert.beginSheetModal (for: inMainWindow)
        ok = false
      }
    }
  //------------- Get archive file size
    var archiveFileSizeData = Data ()
    if ok {
      if let fileAttributes = try? fm.attributesOfItem (atPath: FREEROUTING_ARCHIVE_PATH),
         let archiveFileSize = fileAttributes [.size] as? Int64 {
        archiveFileSizeData = "\(archiveFileSize)".data (using: .utf8)!
      }else{
        let alert = NSAlert ()
        alert.messageText = "Cannot install FreeRouting application"
        alert.informativeText = "Cannot get \"\(FREEROUTING_ARCHIVE_PATH)\" file size"
        alert.beginSheetModal (for: inMainWindow)
        ok = false
      }
    }
  //------------- Check installed release file
    var needsToInstall = true
    if fm.fileExists (atPath: RELEASE_FILE_PATH), let contents = fm.contents (atPath: RELEASE_FILE_PATH) {
      needsToInstall = archiveFileSizeData != contents
    }
  //------------- Install
    if ok && needsToInstall {
   //--- Uncompress freerouter archive
      let task = Process ()
      task.launchPath = "/usr/bin/tar"
      task.arguments = ["-xJf", FREEROUTING_ARCHIVE_PATH]
      task.currentDirectoryURL = URL (fileURLWithPath: FREEROUTING_DIR)
      task.launch ()
      task.waitUntilExit ()
      let status = task.terminationStatus
      // Swift.print ("STATUS \(status)")
      if status != 0 {
        let alert = NSAlert ()
        alert.messageText = "Cannot launch FreeRouting application"
        alert.informativeText = "Application uncompression returns \"\(status)\" status"
        alert.beginSheetModal (for: inMainWindow)
        ok = false
      }
    }
  //--- Uncompress freerouter archive
    if ok && needsToInstall {
      do{
        try archiveFileSizeData.write (to: URL (fileURLWithPath: RELEASE_FILE_PATH))
      }catch _ {
        let alert = NSAlert ()
        alert.messageText = "Cannot launch FreeRouting application"
        alert.informativeText = "Cannot write \"\(RELEASE_FILE_PATH)\" file"
        alert.beginSheetModal (for: self.windowForSheet!)
        ok = false
      }
    }
  //---
 //   Swift.print (ok ? "SUCCESS" : "FAILURE")
    return ok ? URL (fileURLWithPath: FREEROUTING_APPLICATION_PATH) : nil
  }

  //····················································································································

//  func uncompressedFreeRouterURL () -> URL? {
//    if let directory = self.mFreerouterTemporaryApplicationDirectory {
//      return URL (fileURLWithPath: directory + "/Freerouting.app")
//    }else{
//      let fm = FileManager ()
//      let archivePath = systemLibraryPath () + "/freerouter/Freerouting.app.tar.xz"
//    //--- Create temporary directory
//      let h = UInt (bitPattern: Date ().hashValue)
//      let freerouterTemporaryBaseFilePath = NSTemporaryDirectory () + "\(h)/"
//      // Swift.print ("TEMP \(freerouterTemporaryBaseFilePath)")
//      do {
//        try fm.createDirectory (at: URL (fileURLWithPath: freerouterTemporaryBaseFilePath), withIntermediateDirectories: false, attributes: nil)
//      }catch (_) {
//        let alert = NSAlert ()
//        alert.messageText = "Cannot launch FreeRouting application"
//        alert.informativeText = "Cannot create \"\(freerouterTemporaryBaseFilePath)\" directory"
//        alert.beginSheetModal (for: self.windowForSheet!)
//        return nil
//      }
//   //--- Uncompress freerouter archive
//      let task = Process ()
//      task.launchPath = "/usr/bin/tar"
//      task.arguments = ["-xJf", archivePath]
//      task.currentDirectoryURL = URL (fileURLWithPath: freerouterTemporaryBaseFilePath)
//      task.launch ()
//      task.waitUntilExit ()
//      let status = task.terminationStatus
//      // Swift.print ("STATUS \(status)")
//      if status == 0 {
//        self.mFreerouterTemporaryApplicationDirectory = freerouterTemporaryBaseFilePath
//        return URL (fileURLWithPath: freerouterTemporaryBaseFilePath + "/Freerouting.app")
//      }else{
//        let alert = NSAlert ()
//        alert.messageText = "Cannot launch FreeRouting application"
//        alert.informativeText = "Application uncompression returns \"\(status)\" status"
//        alert.beginSheetModal (for: self.windowForSheet!)
//        return nil
//      }
//    }
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
