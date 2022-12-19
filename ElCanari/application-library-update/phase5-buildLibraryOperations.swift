//
//  phase5-buildLibraryOperations.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func phase5_buildLibraryOperations (_ inRepositoryFileDictionary : [String : LibraryContentsDescriptor],
                                               _ inLocalFileSet : Set <String>,
                                               _ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor],
                                               _ inLogTextView : AutoLayoutStaticTextView,
                                               _ inProxy : [String])
                                               -> ([LibraryOperationElement], [String : CanariLibraryFileDescriptor] ) {
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
  var newRepositoryFileDictionary = [String : CanariLibraryFileDescriptor] ()
  for path in allPaths {
    let possibleRepositoryDescriptor = inRepositoryFileDictionary [path]
    let localFileExists = inLocalFileSet.contains (path)
    let possibleLocalDescription = inLibraryFileDictionary [path]
    if let repositoryDescriptor = possibleRepositoryDescriptor, !localFileExists { // Download
      let element = LibraryOperationElement (
        relativePath: path,
        commit: repositoryDescriptor.mCommit,
        sizeInRepository: repositoryDescriptor.mSize,
//        fileSHA: repositoryDescriptor.mSHA,
        operation: .download,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      operations.append (element)
    }else if let repositoryDescriptor = possibleRepositoryDescriptor, possibleLocalDescription == nil { // Update
      let element = LibraryOperationElement (
        relativePath: path,
        commit: repositoryDescriptor.mCommit,
        sizeInRepository: repositoryDescriptor.mSize,
//        fileSHA: repositoryDescriptor.mSHA,
        operation: .update,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      operations.append (element)
    }else if localFileExists && (possibleRepositoryDescriptor == nil) { // Delete file
     let element = LibraryOperationElement (
        relativePath: path,
        commit: 0,
        sizeInRepository: 0,
//        fileSHA: "",
        operation: .delete,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      operations.append (element)
    }else if let repositoryDescriptor = possibleRepositoryDescriptor, let localDescription = possibleLocalDescription { // Update ?
      var upToDate = repositoryDescriptor.mSize == localDescription.size
      if upToDate {
        upToDate = repositoryDescriptor.mSHA == localDescription.sha
      }
      if upToDate {
        if let data = try? Data (contentsOf: URL (fileURLWithPath: systemLibraryPath () + "/" + path)) {
           upToDate = data.count == localDescription.size
           if upToDate {
             upToDate = sha1 (data: data) == localDescription.sha
           }
        }else{
           upToDate = false
        }
      }
      if upToDate {
        newRepositoryFileDictionary [path] = localDescription
      }else{
        let element = LibraryOperationElement (
          relativePath: path,
          commit: repositoryDescriptor.mCommit,
          sizeInRepository: repositoryDescriptor.mSize,
//          fileSHA: repositoryDescriptor.mSHA,
          operation: .update,
          logTextView: inLogTextView,
          proxy: inProxy
        )
        operations.append (element)
      }
    }
  }
  if operations.count == 0 {
    inLogTextView.appendMessageString ("  No operation\n")
  }else{
    inLogTextView.appendMessageString ("  Library operations [operation — file path — size in repository)\n")
    for op in operations {
      inLogTextView.appendMessageString ("    [\(op.operation) — \(op.relativePath) — \(op.sizeInRepository)]\n")
    }
  }
  return (operations, newRepositoryFileDictionary)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
