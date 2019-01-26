//
//  phase5-buildLibraryOperations.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func phase5_buildLibraryOperations (_ inRepositoryFileDictionary : [String : LibraryRepositoryFileDescriptor],
                                    _ inLocalFileSet : Set <String>,
                                    _ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor],
                                    _ inLogTextView : NSTextView,
                                    _ inProxy : [String]) -> [LibraryOperationElement] {
  inLogTextView.appendMessageString ("Phase 5: build operation list\n", color: NSColor.purple)
  inLogTextView.appendMessageString ("  Repository File Dictionary has \(inRepositoryFileDictionary.count) entries\n")
  inLogTextView.appendMessageString ("  Local files: \(inLocalFileSet.count)\n")
  inLogTextView.appendMessageString ("  Library File Dictionary has \(inLibraryFileDictionary.count) entries\n")
//--- Build all path set
  var allPaths = inLocalFileSet
  allPaths.formUnion (inRepositoryFileDictionary.keys)
  allPaths.formUnion (inLibraryFileDictionary.keys)
//--- Iterate over paths
  var operations = [LibraryOperationElement] ()
//  var newRepositoryFileDictionary = [String : LibraryRepositoryFileDescriptor] ()
  for path in allPaths {
    let possibleRepositoryDescriptor = inRepositoryFileDictionary [path]
    let localFileExists = inLocalFileSet.contains (path)
    let possibleLocalDescription = inLibraryFileDictionary [path]
    if let repositoryDescriptor = possibleRepositoryDescriptor, !localFileExists { // Download
      let element = LibraryOperationElement (
        relativePath: path,
        sizeInRepository: repositoryDescriptor.mSizeInRepository,
        operation: .download,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      operations.append (element)
    }else if localFileExists && (possibleRepositoryDescriptor == nil) { // Delete file
     let element = LibraryOperationElement (
        relativePath: path,
        sizeInRepository: 0,
        operation: .delete,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      operations.append (element)
    }else if let repositoryDescriptor = possibleRepositoryDescriptor, let localDescription = possibleLocalDescription { // Download
      let update = repositoryDescriptor.mSizeInRepository != localDescription.mFileSize
      if update {
        let element = LibraryOperationElement (
          relativePath: path,
          sizeInRepository: repositoryDescriptor.mSizeInRepository,
          operation: .update,
          logTextView: inLogTextView,
          proxy: inProxy
        )
        operations.append (element)
      }
    }
  }

//  for descriptor in inLibraryFileDictionary.values {
//    // inLogTextView.appendMessageString ("    \(descriptor.mRelativePath): \(descriptor.mRepositorySHA) \(descriptor.mLocalSHA)\n")
//    if descriptor.mRepositorySHA == "" {
//     inLogTextView.appendMessageString ("    Delete \(descriptor.mRelativePath)\n")
//     let element = LibraryOperationElement (
//        relativePath: descriptor.mRelativePath,
//        sizeInRepository: 0,
//        operation: .delete,
//        logTextView: inLogTextView,
//        proxy: inProxy
//      )
//      outLibraryOperations.append (element)
//    }else if (descriptor.mRepositorySHA != "") && (descriptor.mLocalSHA == "?") {
//      let element = LibraryOperationElement (
//        relativePath: descriptor.mRelativePath,
//        sizeInRepository: descriptor.mSizeInRepository,
//        operation: .download,
//        logTextView: inLogTextView,
//        proxy: inProxy
//      )
//      outLibraryOperations.append (element)
//    }else if (descriptor.mRepositorySHA != descriptor.mLocalSHA) {
//      let element = LibraryOperationElement (
//        relativePath: descriptor.mRelativePath,
//        sizeInRepository: descriptor.mSizeInRepository,
//        operation: .update,
//        logTextView: inLogTextView,
//        proxy: inProxy
//      )
//      outLibraryOperations.append (element)
//    }
//  }
  if operations.count == 0 {
    inLogTextView.appendMessageString ("  No operation\n")
  }else{
    inLogTextView.appendMessageString ("  Library operations [operation — file path — size in repository)\n")
    for op in operations {
      inLogTextView.appendMessageString ("    [\(op.mOperation) — \(op.mRelativePath) — \(op.mSizeInRepository)]\n")
    }
  }
  return operations
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
