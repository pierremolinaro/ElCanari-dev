//
//  extension-AutoLayoutProjectDocument-uncompress-free-router.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let FREEROUTING_DIR = NSHomeDirectory () + "/Library/Application Support/FreeRouterForElCanari"

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func installFreeRouter (_ inMainWindow : NSWindow) -> URL? {
    let FREEROUTING_LEGACY_APPLICATION_PATH = FREEROUTING_DIR + "/Freerouting.app"
    let FREEROUTING_LEGACY_ARCHIVE_PATH = systemLibraryPath () + "/freerouter/Freerouting.app.tar.xz"
    let CHECKSUM_LEGACY_FILE_PATH = FREEROUTING_DIR + "/release.txt"

    let FREEROUTING_X86_APPLICATION_PATH = FREEROUTING_DIR + "/Freerouting-x86_64.app"
    let FREEROUTING_X86_ARCHIVE_PATH = systemLibraryPath () + "/freerouter/Freerouting-x86_64.app.tar.xz"
    let CHECKSUM_X86_FILE_PATH = FREEROUTING_DIR + "/release-x86_64.txt"

    let FREEROUTING_ARM64_APPLICATION_PATH = FREEROUTING_DIR + "/Freerouting-aarch64.app"
    let FREEROUTING_ARM64_ARCHIVE_PATH = systemLibraryPath () + "/freerouter/Freerouting-aarch64.app.tar.xz"
    let CHECKSUM_ARM64_FILE_PATH = FREEROUTING_DIR + "/release-aarch64.txt"
  //------------- FreeRouting directory
    guard self.checkExistsFreeroutingDirectoryOrCreateIt (inMainWindow) else {
      return nil
    }
  //------------- AARCH64 or X86_64 ?
    #if arch(arm64)
      if let url = self.internalInstallFreeRouter (
          fromArchivePath: FREEROUTING_ARM64_ARCHIVE_PATH,
          checksumFilePath: CHECKSUM_ARM64_FILE_PATH,
          freeRoutingApplicationPath: FREEROUTING_ARM64_APPLICATION_PATH,
          inMainWindow
        ) {
        return url
      }
    #else
      if let url = self.internalInstallFreeRouter (
          fromArchivePath: FREEROUTING_X86_ARCHIVE_PATH,
          checksumFilePath: CHECKSUM_X86_FILE_PATH,
          freeRoutingApplicationPath: FREEROUTING_X86_APPLICATION_PATH,
          inMainWindow
        ) {
        return url
      }
    #endif
  //------------- Install legacy application
    return self.internalInstallFreeRouter (
      fromArchivePath: FREEROUTING_LEGACY_ARCHIVE_PATH,
      checksumFilePath: CHECKSUM_LEGACY_FILE_PATH,
      freeRoutingApplicationPath: FREEROUTING_LEGACY_APPLICATION_PATH,
      inMainWindow
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkExistsFreeroutingDirectoryOrCreateIt (_ inMainWindow : NSWindow) -> Bool {
    let fm = FileManager ()
    var ok = fm.fileExists (atPath: FREEROUTING_DIR)
    if !ok {
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
    return ok
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func internalInstallFreeRouter (fromArchivePath inArchivePath : String,
                                              checksumFilePath inChecksumFilePath : String,
                                              freeRoutingApplicationPath inApplicationPath : String,
                                              _ inMainWindow : NSWindow) -> URL? {
    let fm = FileManager ()
    var archiveFileSizeData = Data ()
    var ok = true
    if let fileAttributes = try? fm.attributesOfItem (atPath: inArchivePath),
       let archiveFileSize = fileAttributes [.size] as? Int64 {
      archiveFileSizeData = "\(archiveFileSize)".data (using: .utf8)!
    }else{
      let alert = NSAlert ()
      alert.messageText = "Cannot install FreeRouting application"
      alert.informativeText = "Cannot get \"\(inArchivePath)\" file size"
      alert.beginSheetModal (for: inMainWindow)
      ok = false
    }
  //------------- Check installed release file
    var needsToInstall = true
    if fm.fileExists (atPath: inChecksumFilePath), let contents = fm.contents (atPath: inChecksumFilePath) {
      needsToInstall = archiveFileSizeData != contents
    }
  //------------- Install
    if ok && needsToInstall {
   //--- Uncompress freerouter archive
      let task = Process ()
      task.launchPath = "/usr/bin/tar"
      task.arguments = ["-xJf", inArchivePath]
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
        try archiveFileSizeData.write (to: URL (fileURLWithPath: inChecksumFilePath))
      }catch _ {
        let alert = NSAlert ()
        alert.messageText = "Cannot launch FreeRouting application"
        alert.informativeText = "Cannot write \"\(inChecksumFilePath)\" file"
        alert.beginSheetModal (for: self.windowForSheet!)
        ok = false
      }
    }
  //---
 //   Swift.print (ok ? "SUCCESS" : "FAILURE")
    return ok ? URL (fileURLWithPath: inApplicationPath) : nil
  }

}

//--------------------------------------------------------------------------------------------------
