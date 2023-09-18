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

  func installFreeRouter (_ inMainWindow : NSWindow) -> URL? {
    let fm = FileManager ()
    let freeRouterDirectory = NSHomeDirectory () + "/Library/Application Support/FreeRouterForElCanari"
    let archivePath = systemLibraryPath () + "/freerouter/Freerouting.app.tar.xz"
    let releaseFile = freeRouterDirectory + "/release.txt"
  //------------- Create directory
    var ok = true
    if !fm.fileExists (atPath:freeRouterDirectory) {
      do {
        try fm.createDirectory (at: URL (fileURLWithPath: freeRouterDirectory), withIntermediateDirectories: false, attributes: nil)
      }catch _ {
        let alert = NSAlert ()
        alert.messageText = "Cannot install FreeRouting application"
        alert.informativeText = "Cannot create \"\(freeRouterDirectory)\" directory"
        alert.beginSheetModal (for: inMainWindow) { (NSModalResponse) in }
        ok = false
      }
    }
  //------------- Get archive file size
    var archiveFileSizeData = Data ()
    if ok {
      if let fileAttributes = try? fm.attributesOfItem (atPath: archivePath),
         let archiveFileSize = fileAttributes [.size] as? Int64 {
        archiveFileSizeData = "\(archiveFileSize)".data (using: .utf8)!
      }else{
        let alert = NSAlert ()
        alert.messageText = "Cannot install FreeRouting application"
        alert.informativeText = "Cannot get \"\(archivePath)\" file size"
        alert.beginSheetModal (for: inMainWindow) { (NSModalResponse) in }
        ok = false
      }
    }
  //------------- Check installed release file
    var needsToInstall = true
    if fm.fileExists (atPath: releaseFile), let contents = fm.contents (atPath: releaseFile) {
      needsToInstall = archiveFileSizeData != contents
    }
  //------------- Install
    if ok && needsToInstall {
   //--- Uncompress freerouter archive
      let task = Process ()
      task.launchPath = "/usr/bin/tar"
      task.arguments = ["-xJf", archivePath]
      task.currentDirectoryURL = URL (fileURLWithPath: freeRouterDirectory)
      task.launch ()
      task.waitUntilExit ()
      let status = task.terminationStatus
      // Swift.print ("STATUS \(status)")
      if status != 0 {
        let alert = NSAlert ()
        alert.messageText = "Cannot launch FreeRouting application"
        alert.informativeText = "Application uncompression returns \"\(status)\" status"
        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
        ok = false
      }
    }
  //--- Uncompress freerouter archive
    if ok && needsToInstall {
      do{
        try archiveFileSizeData.write (to: URL (fileURLWithPath: releaseFile))
       // Swift.print ("INSTALLED")
      }catch _ {
        let alert = NSAlert ()
        alert.messageText = "Cannot launch FreeRouting application"
        alert.informativeText = "Cannot write \"\(releaseFile)\" file"
        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
        ok = false
      }
    }
  //---
 //   Swift.print (ok ? "SUCCESS" : "FAILURE")
    return ok ? URL (fileURLWithPath: freeRouterDirectory + "/FreeRouting.app") : nil
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
//        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
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
//        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
//        return nil
//      }
//    }
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
