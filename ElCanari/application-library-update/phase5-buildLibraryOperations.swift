//
//  phase5-buildLibraryOperations.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func phase5_buildLibraryOperations (_ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor],
                                    _ outLibraryOperations : inout [LibraryOperationElement],
                                    _ inLogTextView : NSTextView,
                                    _ inProxy : [String]) {
  inLogTextView.appendMessageString ("Phase 5: build operation list\n", color: NSColor.purple)
  inLogTextView.appendMessageString ("  Library File Dictionary has \(inLibraryFileDictionary.count) entries\n")
  for descriptor in inLibraryFileDictionary.values {
    // inLogTextView.appendMessageString ("    \(descriptor.mRelativePath): \(descriptor.mRepositorySHA) \(descriptor.mLocalSHA)\n")
    if descriptor.mRepositorySHA == "" {
     inLogTextView.appendMessageString ("    Delete \(descriptor.mRelativePath)\n")
     let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: 0,
        operation: .delete,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      outLibraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != "") && (descriptor.mLocalSHA == "?") {
      let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: descriptor.mSizeInRepository,
        operation: .download,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      outLibraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != descriptor.mLocalSHA) {
      let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: descriptor.mSizeInRepository,
        operation: .update,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      outLibraryOperations.append (element)
    }
  }
  if outLibraryOperations.count == 0 {
    inLogTextView.appendMessageString ("  No operation\n")
  }else{
    inLogTextView.appendMessageString ("  Library operations (operation:file path:size in repository)\n")
    for op in outLibraryOperations {
      inLogTextView.appendMessageString ("    \(op.mOperation):\(op.mRelativePath):\(op.mSizeInRepository)\n")
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
