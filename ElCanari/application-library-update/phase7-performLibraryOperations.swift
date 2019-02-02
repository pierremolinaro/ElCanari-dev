//
//  phase7-performLibraryOperations.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let parallelDownloadCount = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gCanariLibraryUpdateController : CanariLibraryUpdateController? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func phase7_performLibraryOperations (_ inLibraryOperations : [LibraryOperationElement],
                                      _ inNewLocalDescriptionDictionary : [String : CanariLibraryFileDescriptor],
                                      _ inLogTextView : NSTextView) {
  inLogTextView.appendMessageString ("Phase 7: Display Update Dialog and perform operation\n", color: NSColor.purple)
//--- Perform library update in main thread
  DispatchQueue.main.async  {
  //--- Configure informative text in library update window
    if inLibraryOperations.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(inLibraryOperations.count) elements to update"
    }
    var progressMaxValue = 0.0
    for action in inLibraryOperations {
      progressMaxValue += action.maxIndicatorValue
    }
  //--- Enable buttons
    g_Preferences?.mUpDateButtonInLibraryUpdateWindow?.isEnabled = true
    g_Preferences?.mCancelButtonInLibraryUpdateWindow?.isEnabled = true
  //--- Configure progress indicator in library update window
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.minValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.maxValue = progressMaxValue
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.isIndeterminate = false
  //--- Configure table view in library update window
    gCanariLibraryUpdateController = CanariLibraryUpdateController (inLibraryOperations, inNewLocalDescriptionDictionary, inLogTextView)
    gCanariLibraryUpdateController?.bind ()
  //--- Show library update window
    g_Preferences?.mLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdate () {
  g_Preferences?.mUpDateButtonInLibraryUpdateWindow?.isEnabled = false
//--- Launch parallel downloads
  for _ in 1...parallelDownloadCount {
    gCanariLibraryUpdateController?.launchElementDownload ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cancelLibraryUpdate () {
  g_Preferences?.mCancelButtonInLibraryUpdateWindow?.window?.orderOut (nil)
//--- Cancel current downloadings
  gCanariLibraryUpdateController?.cancel ()
  startLibraryUpdate ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   C O M M I T    U P D A T E S   I N   F I L E    S Y S T E M
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func commitAllActions (_ inActionArray : [LibraryOperationElement],
                       _ inNewRepositoryFileDictionary : [String : CanariLibraryFileDescriptor],
                       _ inLogTextView : NSTextView) {
//--- Update UI
  gCanariLibraryUpdateController?.unbind ()
  gCanariLibraryUpdateController = nil
//--- Commit change only if all actions has been successdully completed
  var newRepositoryFileDictionary = inNewRepositoryFileDictionary
  var performCommit = true
  for action in inActionArray {
    switch action.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      performCommit = false
    case .deleteRegistered :
      ()
    case .downloaded (let data) :
      let newDescriptor = CanariLibraryFileDescriptor (
        fileSize: data.count,
        blobSHA: action.mBlobSHA,
        fileContentSHA: sha1 (data)
      )
      newRepositoryFileDictionary [action.mRelativePath] = newDescriptor
    }
  }
//--- Perform commit
  if !performCommit {
    g_Preferences?.mLibraryUpdateWindow?.orderOut (nil)
    enableItemsAfterCompletion ()
  }else{
    if let window = g_Preferences?.mLibraryUpdateWindow {
      do{
        for action in inActionArray {
          try action.commit ()
        }
      //--- Delete orphean directories
        try deleteOrphanDirectories (inLogTextView)
      //--- Write library description plist file
        try writeLibraryDescriptionPlistFile (newRepositoryFileDictionary, inLogTextView)
      //--- Completed!
        let alert = NSAlert ()
        alert.messageText = "Update completed, the library is up to date"
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : NSApplication.ModalResponse) in window.orderOut (nil) ; enableItemsAfterCompletion () }
        )
      }catch let error {
        let alert = NSAlert ()
        alert.messageText = "Cannot commit changes"
        alert.informativeText = "A file system operation returns \(error) error"
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : NSApplication.ModalResponse) in window.orderOut (nil) ; enableItemsAfterCompletion () }
        )
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    deleteOrphanDirectories
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func deleteOrphanDirectories (_ inLogTextView : NSTextView) throws {
  let fm = FileManager ()
  let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
  var directoryArray = [String] ()
  for relativePath in currentLibraryContents {
    let fullPath = systemLibraryPath () + "/" + relativePath
    var isDirectory : ObjCBool = false
    fm.fileExists (atPath: fullPath, isDirectory: &isDirectory)
    if (isDirectory.boolValue) {
      directoryArray.append (fullPath)
    }
  }
  directoryArray.sort ()
  var i=directoryArray.count-1
  while i>=0 {
    let fullPath = directoryArray [i]
    var currentDirectoryContents = try fm.contentsOfDirectory (atPath: fullPath)
  //--- Remove .DS_Store files
    var j=0
    while j<currentDirectoryContents.count {
      let s = currentDirectoryContents [j]
      if s == ".DS_Store" {
        currentDirectoryContents.remove (at: j)
        j -= 1
      }
      j += 1
    }
    if (currentDirectoryContents.count == 0) {
      inLogTextView.appendMessageString ("  Delete orphean directory at '\(fullPath)\n")
      try fm.removeItem (atPath: fullPath)
    }
    i -= 1
  }
  enableItemsAfterCompletion ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
