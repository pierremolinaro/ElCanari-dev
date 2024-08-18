//--------------------------------------------------------------------------------------------------
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func phase3_readLibraryDescriptionFileContents () -> [String : CanariLibraryFileDescriptor] {
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 3: enumerate local files\n", color: NSColor.purple)
    var libraryFileDictionary = [String : CanariLibraryFileDescriptor] ()
    if let propertyList = libraryDescriptionFileContents () {
      for entry in propertyList {
        if let filePath = entry ["path"] as? String,
           let fileSHA = entry ["sha"] as? String,
           let commit = entry ["commit"] as? Int,
           let fileSize = entry ["size"] as? Int {
          let newDescriptor = CanariLibraryFileDescriptor (
            size: fileSize,
            sha: fileSHA,
            commit: commit
          )
          libraryFileDictionary [filePath] = newDescriptor
        }
      }
    }
  //--- Print
    self.mLibraryUpdateLogTextView.appendMessageString ("  Local contents, from description file [path — commit — size — sha]:\n")
    for (path, value) in libraryFileDictionary {
      self.mLibraryUpdateLogTextView.appendMessageString ("    [\(path) — \(value.commit) — \(value.size) — \(value.sha)]\n")
    }
    return libraryFileDictionary
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func writeLibraryDescriptionPlistFile (_ inRepositoryFileDictionary: [String : CanariLibraryFileDescriptor]) throws {
    self.mLibraryUpdateLogTextView.appendMessageString ("  Write Library Description Plist File [path — repositorySHA — size]\n")
    for (path, value) in inRepositoryFileDictionary {
      self.mLibraryUpdateLogTextView.appendMessageString ("    [\(path) — \(value.sha) — \(value.size)]\n")
    }
  //--- Write plist file
    var dictionaryArray = [[String : Any]] ()
    var lastCommit = 0
    for (path, descriptor) in inRepositoryFileDictionary {
      let dictionary : [String : Any] = [
        "path" : path,
        "commit" : descriptor.commit,
        "size" : descriptor.size,
        "sha" : descriptor.sha
      ]
      lastCommit = max (lastCommit, descriptor.commit)
      dictionaryArray.append (dictionary)
    }
    let data : Data = try PropertyListSerialization.data (fromPropertyList: dictionaryArray, format: .binary, options: 0)
    let f = systemLibraryPath () + "/" + REPOSITORY_DESCRIPTION_PLIST_FILE_NAME
    try data.write (to: URL (fileURLWithPath: f))
    storeRepositoryFileSHA (sha1 (data: data))
    storeRepositoryCurrentCommit (lastCommit)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

struct CanariLibraryFileDescriptor {

  let size : Int
  let sha : String
  let commit : Int

}

//--------------------------------------------------------------------------------------------------
