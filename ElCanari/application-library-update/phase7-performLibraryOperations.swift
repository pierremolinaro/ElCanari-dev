//
//  phase7-performLibraryOperations.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gCanariLibraryUpdateController : CanariLibraryUpdateController? = nil

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func phase7_performLibraryOperations (_ inLibraryOperations : [LibraryOperationElement],
                                        _ inNewLocalDescriptionDictionary : [String : CanariLibraryFileDescriptor]) {
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 7: Display Update Dialog and perform operation\n", color: NSColor.purple)
  //--- Perform library update in main thread
    DispatchQueue.main.async {
    //--- Configure informative text in library update window
      let inInformativeText : String
      if inLibraryOperations.count == 1 {
        inInformativeText = "1 element to update"
     }else{
        inInformativeText = "\(inLibraryOperations.count) elements to update"
      }
      var progressMaxValue = 0.0
      for action in inLibraryOperations {
        progressMaxValue += action.maxIndicatorValue
      }
    //--- Configure table view in library update window
      gCanariLibraryUpdateController = CanariLibraryUpdateController (
        inLibraryOperations,
        inNewLocalDescriptionDictionary,
        progressMaxValue,
        inInformativeText
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   C O M M I T    U P D A T E S   I N   F I L E    S Y S T E M
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func commitAllActions (_ inActionArray : [LibraryOperationElement],
                         _ inNewRepositoryFileDictionary : [String : CanariLibraryFileDescriptor]) {
  //--- Commit change only if all actions has been successdully completed
    var newRepositoryFileDictionary = inNewRepositoryFileDictionary
    var performCommit = true
    for action in inActionArray {
      switch action.operation {
      case .download, .update, .downloadError, .downloading, .delete :
        performCommit = false
      case .deleteRegistered :
        ()
      case .downloaded (let data) :
        let newDescriptor = CanariLibraryFileDescriptor (
          size: data.count,
          sha: sha1 (data: data),
          commit: action.commit
        )
        newRepositoryFileDictionary [action.relativePath] = newDescriptor
      }
    }
  //--- Perform commit
    if !performCommit {
      gCanariLibraryUpdateController?.orderOutLibraryUpdatePanel ()
      self.enableItemsAfterCompletion ()
    }else if let window = gCanariLibraryUpdateController?.panelForSheet () {
      do{
        for action in inActionArray {
          try action.performCommit ()
        }
      //--- Delete orphean directories
        try self.deleteOrphanDirectories ()
      //--- Write library description plist file
        try self.writeLibraryDescriptionPlistFile (newRepositoryFileDictionary)
      //--- Completed!
        self.mLibraryUpdateLogTextView.appendSuccessString ("Done.")
        let alert = NSAlert ()
        alert.messageText = "Update completed, the library is up to date"
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : NSApplication.ModalResponse) in
            DispatchQueue.main.async {
              window.orderOut (nil)
              self.enableItemsAfterCompletion ()
            }
          }
        )
      }catch let error {
        let alert = NSAlert ()
        alert.messageText = "Cannot commit changes"
        alert.informativeText = "A file system operation returns \(error) error"
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : NSApplication.ModalResponse) in
            DispatchQueue.main.async {
              window.orderOut (nil)
              self.enableItemsAfterCompletion ()
            }
          }
        )
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    deleteOrphanDirectories
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func deleteOrphanDirectories () throws {
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
    var i = directoryArray.count - 1
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
        self.mLibraryUpdateLogTextView.appendMessageString ("  Delete orphean directory at '\(fullPath)\n")
        try fm.removeItem (atPath: fullPath)
      }
      i -= 1
    }
    enableItemsAfterCompletion ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
