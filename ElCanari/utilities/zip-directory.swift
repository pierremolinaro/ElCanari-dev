//
//  zip-directory.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/06/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

func writeZipArchiveFile (at inTargetZipURL : URL,
                          fromDirectoryURL inSourceDirectoryURL : URL) throws {
  let coord = NSFileCoordinator ()
  var myError1 : NSError? = nil
  var myError2 : NSError? = nil
// coordinateReadingItemAtURL is invoked synchronously, but the passed in zippedURL is only valid
// for the duration of the block, so it needs to be copied out
  coord.coordinate (readingItemAt: inSourceDirectoryURL,
                    options: NSFileCoordinator.ReadingOptions.forUploading,
                    error: &myError1) { (inZippedURL : URL) -> Void in
    do{
      let fm = FileManager ()
      if fm.fileExists (atPath: inTargetZipURL.path) {
        try fm.removeItem (at: inTargetZipURL)
      }
      try fm.copyItem (at: inZippedURL, to: inTargetZipURL)
    }catch let error {
      myError2 = error as NSError
    }
  }
  if let error = myError1 {
    throw error
  }else if let error = myError2 {
    throw error
  }
}

//--------------------------------------------------------------------------------------------------
