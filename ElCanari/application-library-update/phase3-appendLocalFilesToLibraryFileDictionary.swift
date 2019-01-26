//
//  phase3-appendLocalFilesToLibraryFileDictionary.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func phase3_appendLocalFilesToLibraryFileDictionary (_ ioLibraryFileDictionary : inout [String : CanariLibraryFileDescriptor],
                                                     _ inLogTextView : NSTextView,
                                                     _ ioPossibleAlert : inout NSAlert?) {
  do{
    inLogTextView.appendMessageString ("  System Library path is \(systemLibraryPath ())\n")
    let fm = FileManager ()
    if fm.fileExists (atPath: systemLibraryPath ()) {
      let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
      for filePath in currentLibraryContents {
      //--- Eliminate ".DS_store" and description plist file
        var enter = (filePath.lastPathComponent != ".DS_Store") && (filePath != repositoryDescriptionFile)
      //--- Eliminate directories
        if enter {
          let fullPath = systemLibraryPath () + "/" + filePath
          var isDirectory : ObjCBool = false
          _ = fm.fileExists (atPath:fullPath, isDirectory: &isDirectory)
          enter = !isDirectory.boolValue
        }
        if enter {
          if let descriptor = ioLibraryFileDictionary [filePath] {
            let localSHA = try computeFileSHA (filePath)
            let newDescriptor = CanariLibraryFileDescriptor (
              relativePath: descriptor.mRelativePath,
              repositorySHA: descriptor.mRepositorySHA,
              sizeInRepository: descriptor.mSizeInRepository,
              localSHA: localSHA
            )
            ioLibraryFileDictionary [filePath] = newDescriptor
          }else{
            let descriptor = CanariLibraryFileDescriptor (
              relativePath: filePath,
              repositorySHA: "",
              sizeInRepository: 0,
              localSHA: "?"
            )
            ioLibraryFileDictionary [filePath] = descriptor
          }
        }
      }
      inLogTextView.appendMessageString ("  System Library directory contents:\n")
      inLogTextView.appendMessageString ("    local SHA:repository SHA:SHA:repository size:file path\n")
      for descriptor in ioLibraryFileDictionary.values {
        inLogTextView.appendMessageString ("    \(descriptor.mLocalSHA):\(descriptor.mRepositorySHA):\(descriptor.mSizeInRepository):\(descriptor.mRelativePath)\n")
      }
    }else{
      inLogTextView.appendWarningString ("  System Library directory does not exist\n")
    }
  }catch let error {
    inLogTextView.appendErrorString ("  Switch exception \(error)\n")
    ioPossibleAlert = NSAlert (error: error)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
