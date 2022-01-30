//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func phase2_readOrDownloadLibraryFileDictionary (_ possibleStoredCurrentCommit : Int?,
                                                 _ remoteCurrentCommit : Int,
                                                 _ inLogTextView : AutoLayoutStaticTextView,
                                                 _ inProxy : [String],
                                                 _ ioPossibleAlert : inout NSAlert?) -> [String : LibraryContentsDescriptor] {
  var libraryFileDictionary = [String : LibraryContentsDescriptor] ()
  inLogTextView.appendMessageString ("Phase 2: get repository commit file\n", color: NSColor.purple)
//--- Use local description file ?
  var needsToDowloadDescriptionFile = true
  if let storedCurrentCommit = possibleStoredCurrentCommit, storedCurrentCommit == remoteCurrentCommit {
    let localDescriptionFile = systemLibraryPath () + "/" + REPOSITORY_DESCRIPTION_PLIST_FILE_NAME
    if let data = try? Data (contentsOf: URL (fileURLWithPath: localDescriptionFile)) {
      let possibleDictArray = try? PropertyListSerialization.propertyList (from: data, format: nil)
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
    inLogTextView.appendMessageString ("  Using '\(REPOSITORY_DESCRIPTION_PLIST_FILE_NAME)' local file\n")
  }
//--- Download from repository
  if needsToDowloadDescriptionFile, let data = getRemoteFileData ("contents/contents-\(remoteCurrentCommit).plist", &ioPossibleAlert, inLogTextView, inProxy) {
    libraryFileDictionary = [String : LibraryContentsDescriptor] ()
    let possibleDictArray = try? PropertyListSerialization.propertyList (from: data, format: nil)
    if let dictArray = possibleDictArray as? [[String : Any]] {
      for dictionary : [String : Any] in dictArray {
        if let entry = LibraryContentsDescriptor (withDictionary: dictionary) {
          libraryFileDictionary [entry.mRelativePath] = entry
        }else{
          inLogTextView.appendErrorString ("  Contents file has an invalid structure.\n")
          ioPossibleAlert = NSAlert ()
          ioPossibleAlert?.messageText = "Internal error"
          ioPossibleAlert?.informativeText = "Contents file has an invalid structure."
        }
      }
    }else{
      inLogTextView.appendErrorString ("  Contents file has an invalid structure.\n")
      ioPossibleAlert = NSAlert ()
      ioPossibleAlert?.messageText = "Internal error"
      ioPossibleAlert?.informativeText = "Contents file has an invalid structure."
    }
  }
//--- Print
  inLogTextView.appendMessageString ("  Repository contents [path — commit — size — sha]:\n")
  for (path, value) in libraryFileDictionary {
    inLogTextView.appendMessageString ("    [\(path) — \(value.mCommit) — \(value.mSize) — \(value.mSHA)]\n")
  }
  return libraryFileDictionary
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
