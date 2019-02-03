//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

 func phase3_readLibraryDescriptionFileContents (_ inLogTextView : NSTextView) -> [String : CanariLibraryFileDescriptor] {
  inLogTextView.appendMessageString ("Phase 3: enumerate local files\n", color: NSColor.purple)
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
  inLogTextView.appendMessageString ("  Local contents, from description file [path — commit — size — sha]:\n")
  for (path, value) in libraryFileDictionary {
    inLogTextView.appendMessageString ("    [\(path) — \(value.mCommit) — \(value.mSize) — \(value.mSHA)]\n")
  }
  return libraryFileDictionary
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func writeLibraryDescriptionPlistFile (_ inRepositoryFileDictionary: [String : CanariLibraryFileDescriptor],
                                       _ inLogTextView : NSTextView) throws {
  inLogTextView.appendMessageString ("  Write Library Description Plist File [path — repositorySHA — size]\n")
  for (path, value) in inRepositoryFileDictionary {
    inLogTextView.appendMessageString ("    [\(path) — \(value.mSHA) — \(value.mSize)]\n")
  }
//--- Write plist file
  var dictionaryArray = [[String : Any]] ()
  var lastCommit = 0
  for (path, descriptor) in inRepositoryFileDictionary {
    let dictionary : [String : Any] = [
      "path" : path,
      "commit" : descriptor.mCommit,
      "size" : descriptor.mSize,
      "sha" : descriptor.mSHA
    ]
    lastCommit = max (lastCommit, descriptor.mCommit)
    dictionaryArray.append (dictionary)
  }
  let data : Data = try PropertyListSerialization.data (fromPropertyList: dictionaryArray, format: .binary, options: 0)
  let f = systemLibraryPath () + "/" + REPOSITORY_DESCRIPTION_PLIST_FILE_NAME
  try data.write (to: URL (fileURLWithPath: f))
  storeRepositoryFileSHA (sha1 (data))
  storeRepositoryCurrentCommit (lastCommit)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariLibraryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mSize : Int
  let mSHA : String
  let mCommit : Int

  //····················································································································

  init (size inSize : Int,
        sha inSHA : String,
        commit inCommit : Int) {
    mSize = inSize
    mSHA = inSHA
    mCommit = inCommit
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
