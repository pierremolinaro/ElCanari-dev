//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

 func phase3_enumerateLocalFiles (_ inLogTextView : NSTextView) -> [String : CanariLibraryFileDescriptor] {
  inLogTextView.appendMessageString ("Phase 3: enumerate local files\n", color: NSColor.purple)
  var libraryFileDictionary = [String : CanariLibraryFileDescriptor] ()
  if let propertyList = libraryDescriptionFileContents () {
    for entry in propertyList {
      if let filePath = entry ["path"] as? String,
         let repositorySHA = entry ["sha"] as? String,
         let fileSize = entry ["size"] as? Int {
        let newDescriptor = CanariLibraryFileDescriptor (
          fileSize: fileSize,
          fileContentSHA: repositorySHA
        )
        libraryFileDictionary [filePath] = newDescriptor
      }
    }
  }
//--- Print
  inLogTextView.appendMessageString ("  Local contents, from description file [path — size — fileContentSHA]:\n")
  for (path, value) in libraryFileDictionary {
    inLogTextView.appendMessageString ("    [\(path) — \(value.mFileSize) — \(value.mFileContentSHA)]\n")
  }
  return libraryFileDictionary
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariLibraryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mFileSize : Int
  let mFileContentSHA : String

  //····················································································································

  init (fileSize inFileSize : Int,
        fileContentSHA inFileContentSHA : String) {
    mFileSize = inFileSize
    mFileContentSHA = inFileContentSHA
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
