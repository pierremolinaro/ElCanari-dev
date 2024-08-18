//
//  phase4-appendLocalFilesToLibraryFileDictionary.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let REPOSITORY_DESCRIPTION_PLIST_FILE_NAME = "repository-description.plist"

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func phase4_appendLocalFilesToLibraryFileDictionary (_ ioPossibleAlert : inout NSAlert?) -> Set <String> {
    var libraryFileDictionary = Set <String> ()
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 4: enumerate local system library\n", color: NSColor.purple)
    do{
      self.mLibraryUpdateLogTextView.appendMessageString ("  System Library path is \(systemLibraryPath ())\n")
      let fm = FileManager ()
      if fm.fileExists (atPath: systemLibraryPath ()) {
        let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
        for filePath in currentLibraryContents {
        //--- Eliminate ".DS_store" and description plist file
          var enter = (filePath.lastPathComponent != ".DS_Store") && (filePath != REPOSITORY_DESCRIPTION_PLIST_FILE_NAME)
        //--- Eliminate directories
          if enter {
            let fullPath = systemLibraryPath () + "/" + filePath
            var isDirectory : ObjCBool = false
            _ = fm.fileExists (atPath: fullPath, isDirectory: &isDirectory)
            enter = !isDirectory.boolValue
          }
          if enter {
            libraryFileDictionary.insert (filePath)
          }
        }
        self.mLibraryUpdateLogTextView.appendMessageString ("  System Library directory contents [file path]:\n")
        for descriptor in libraryFileDictionary {
          self.mLibraryUpdateLogTextView.appendMessageString ("    [\(descriptor)]\n")
        }
      }else{
        self.mLibraryUpdateLogTextView.appendWarningString ("  System Library directory does not exist\n")
      }
    }catch let error {
      self.mLibraryUpdateLogTextView.appendErrorString ("  Switch exception \(error)\n")
      ioPossibleAlert = NSAlert (error: error)
    }
    return libraryFileDictionary
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
