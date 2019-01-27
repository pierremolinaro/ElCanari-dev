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
         let blobSHA = entry ["blob-sha"] as? String,
         let fileContentSHA = entry ["file-sha"] as? String,
         let fileSize = entry ["size"] as? Int {
        let newDescriptor = CanariLibraryFileDescriptor (
          fileSize: fileSize,
          blobSHA: blobSHA,
          fileContentSHA: fileContentSHA
        )
        libraryFileDictionary [filePath] = newDescriptor
      }
    }
  }
//--- Print
  inLogTextView.appendMessageString ("  Local contents, from description file [path — blob SHA — size — fileContentSHA]:\n")
  for (path, value) in libraryFileDictionary {
    inLogTextView.appendMessageString ("    [\(path) — \(value.mBlobSHA) — \(value.mFileSize) — \(value.mFileContentSHA)]\n")
  }
  return libraryFileDictionary
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func writeLibraryDescriptionPlistFile (_ inRepositoryFileDictionary: [String : CanariLibraryFileDescriptor],
                                       _ inLogTextView : NSTextView) throws {
  inLogTextView.appendMessageString ("  Write Library Description Plist File [path — repositorySHA — size]\n")
  for (path, value) in inRepositoryFileDictionary {
    inLogTextView.appendMessageString ("    [\(path) — \(value.mFileContentSHA) — \(value.mFileSize)]\n")
  }
//--- Write plist file
  var dictionaryArray = [[String : Any]] ()
  for (path, descriptor) in inRepositoryFileDictionary {
    let dictionary : [String : Any] = [
      "path" : path,
      "size" : descriptor.mFileSize,
      "blob-sha" : descriptor.mBlobSHA,
      "file-sha" : descriptor.mFileContentSHA
    ]
    dictionaryArray.append (dictionary)
  }
  let data : Data = try PropertyListSerialization.data (fromPropertyList: dictionaryArray, format: .binary, options: 0)
  let f = systemLibraryPath () + "/" + REPOSITORY_DESCRIPTION_PLIST_FILE_NAME
  try data.write (to: URL (fileURLWithPath: f))
  storeRepositoryFileSHA (sha1 (data))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariLibraryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mFileSize : Int
  let mBlobSHA : String
  let mFileContentSHA : String

  //····················································································································

  init (fileSize inFileSize : Int,
        blobSHA inBlobSHA : String,
        fileContentSHA inFileContentSHA : String) {
    mFileSize = inFileSize
    mBlobSHA = inBlobSHA
    mFileContentSHA = inFileContentSHA
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
