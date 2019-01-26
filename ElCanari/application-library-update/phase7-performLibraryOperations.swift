//
//  phase6-performLibraryOperations.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let parallelDownloadCount = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gCanariLibraryUpdateController = CanariLibraryUpdateController ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func phase6_performLibraryOperations (_ inLibraryOperations : [LibraryOperationElement],
                                      _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor],
                                      _ inLogTextView : NSTextView) {
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
  //--- Configure progress indicator in library update window
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.minValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.maxValue = progressMaxValue
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.isIndeterminate = false
  //--- Configure table view in library update window
    gCanariLibraryUpdateController = CanariLibraryUpdateController (inLibraryOperations, inRepositoryFileDictionary, inLogTextView)
    gCanariLibraryUpdateController.bind ()
  //--- Show library update window
    g_Preferences?.mLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdate () {
//--- Launch parallel downloads
  for _ in 1...parallelDownloadCount {
    gCanariLibraryUpdateController.launchElementDownload ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cancelLibraryUpdate () {
//--- Cancel current downloadings
  gCanariLibraryUpdateController.cancel ()
  startLibraryUpdate ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   C O M M I T    U P D A T E S   I N   F I L E    S Y S T E M
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func commitAllActions (_ inActionArray : [LibraryOperationElement],
                       _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor],
                       _ inLogTextView : NSTextView) {
//--- Update UI
  gCanariLibraryUpdateController.unbind ()
  let logTextView = gCanariLibraryUpdateController.logTextView
  gCanariLibraryUpdateController = CanariLibraryUpdateController ()
//--- Commit change only if all actions has been successdully completed
  var repositoryFileDictionary = inRepositoryFileDictionary
  var performCommit = true
  for action in inActionArray {
    switch action.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      performCommit = false
    case .deleteRegistered :
      ()
    case .downloaded (let data) :
      var descriptor = repositoryFileDictionary [action.mRelativePath]!
      descriptor.mRepositorySHA = sha1 (data)
      repositoryFileDictionary [action.mRelativePath] = descriptor
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
        try deleteOrphanDirectories (logTextView)
      //--- Write library description plist file
        try writeLibraryDescriptionPlistFile (repositoryFileDictionary, inLogTextView)
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

private func writeLibraryDescriptionPlistFile (
        _ inRepositoryFileDictionary: [String : CanariLibraryFileDescriptor],
        _ inLogTextView : NSTextView) throws {
  inLogTextView.appendMessageString ("  Write Library Description Plist File (repositorySHA:size:path)\n")
  for (path, value) in inRepositoryFileDictionary {
    inLogTextView.appendMessageString ("    \(value.mRepositorySHA):\(value.mSizeInRepository):\(path)\n")
  }
//--- Write plist file
  var dictionaryArray = [[String : String]] ()
  for descriptor in inRepositoryFileDictionary.values {
    var dictionary = [String : String] ()
    dictionary ["path"] = descriptor.mRelativePath
    dictionary ["size"] = "\(descriptor.mSizeInRepository)"
    dictionary ["sha"] = descriptor.mRepositorySHA
    dictionaryArray.append (dictionary)
  }
  let data : Data = try PropertyListSerialization.data (fromPropertyList: dictionaryArray, format: .binary, options: 0)
  let f = systemLibraryPath () + "/" + repositoryDescriptionFile
  try data.write (to: URL (fileURLWithPath: f))
  storeRepositoryFileSHA (sha1 (data))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariLibraryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  var mRepositorySHA : String
  let mSizeInRepository : Int
  let mLocalSHA : String

  //····················································································································

  init (relativePath inRelativePath : String,
        repositorySHA inRepositorySHA : String,
        sizeInRepository inSizeInRepository : Int,
        localSHA inLocalSHA : String) {
    mRelativePath = inRelativePath
    mRepositorySHA = inRepositorySHA
    mLocalSHA = inLocalSHA
    mSizeInRepository = inSizeInRepository
  }

  //····················································································································

}

