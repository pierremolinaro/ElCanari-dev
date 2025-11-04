//--------------------------------------------------------------------------------------------------
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func phase2_readOrDownloadLibraryFileDictionary (_ inPossibleStoredCurrentCommit : Int?,
                                                   _ inRemoteCurrentCommit : Int,
                                                   _ inProxy : [String],
                                                   _ ioPossibleAlert : inout NSAlert?) -> [String : LibraryContentsDescriptor] {
    var libraryFileDictionary = [String : LibraryContentsDescriptor] ()
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 2: get repository commit file\n", color: NSColor.purple)
  //--- Use local description file ?
    var needsToDowloadDescriptionFile = true
    if let storedCurrentCommit = inPossibleStoredCurrentCommit, storedCurrentCommit == inRemoteCurrentCommit {
      let localDescriptionFile = systemLibraryPath () + "/" + REPOSITORY_DESCRIPTION_PLIST_FILE_NAME
      if let data = try? Data (contentsOf: URL (fileURLWithPath: localDescriptionFile)) {
        let possibleDictArray = unsafe try? PropertyListSerialization.propertyList (from: data, format: nil)
        if let dictArray = possibleDictArray as? [[String : Any]] {
          needsToDowloadDescriptionFile = false
          for dictionary : [String : Any] in dictArray {
            if let entry = LibraryContentsDescriptor (withDictionary: dictionary) {
              libraryFileDictionary [entry.mRelativePath] = entry
            }else{
              needsToDowloadDescriptionFile = true
            }
          }
        }
      }
    }
    if !needsToDowloadDescriptionFile {
      self.mLibraryUpdateLogTextView.appendMessageString ("  Using '\(REPOSITORY_DESCRIPTION_PLIST_FILE_NAME)' local file\n")
    }
  //--- Download from repository
    if needsToDowloadDescriptionFile, let data = self.getRemoteFileData ("contents/contents-\(inRemoteCurrentCommit).plist", &ioPossibleAlert, inProxy) {
      libraryFileDictionary = [String : LibraryContentsDescriptor] ()
      let possibleDictArray = unsafe try? PropertyListSerialization.propertyList (from: data, format: nil)
      if let dictArray = possibleDictArray as? [[String : Any]] {
        for dictionary : [String : Any] in dictArray {
          if let entry = LibraryContentsDescriptor (withDictionary: dictionary) {
            libraryFileDictionary [entry.mRelativePath] = entry
          }else{
            self.mLibraryUpdateLogTextView.appendErrorString ("  Contents file has an invalid structure.\n")
            ioPossibleAlert = NSAlert ()
            ioPossibleAlert?.messageText = "Internal error"
            ioPossibleAlert?.informativeText = "Contents file has an invalid structure."
          }
        }
      }else{
        self.mLibraryUpdateLogTextView.appendErrorString ("  Contents file has an invalid structure.\n")
        ioPossibleAlert = NSAlert ()
        ioPossibleAlert?.messageText = "Internal error"
        ioPossibleAlert?.informativeText = "Contents file has an invalid structure."
      }
    }
  //--- Print
    self.mLibraryUpdateLogTextView.appendMessageString ("  Repository contents [path — commit — size — sha]:\n")
    for (path, value) in libraryFileDictionary {
      self.mLibraryUpdateLogTextView.appendMessageString ("    [\(path) — \(value.mCommit) — \(value.mSize) — \(value.mSHA)]\n")
    }
    return libraryFileDictionary
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
