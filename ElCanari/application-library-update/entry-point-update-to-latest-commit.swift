
import AppKit

//--------------------------------------------------------------------------------------------------

let CURL = "/usr/bin/curl"

//--------------------------------------------------------------------------------------------------
//   LIBRARY UPDATE ENTRY POINT
//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func startLibraryUpdateOperation (showProgressWindow inShowWindow : Bool) {
    self.mLibraryUpdateLogTextView.appendMessageString ("Start library update operation\n", color: NSColor.blue)
  //--- Disable update buttons
    self.mCheckForLibraryUpdatesButton?.isEnabled = false
    appDelegate ()?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
  //-------- Cleat log window
    self.mLibraryUpdateLogTextView.clear ()
  //-------- Show "Check for update" window
    if inShowWindow {
      self.showCheckingForLibraryUpdateWindow ()
    }
  //-------- ⓪ Get system proxy
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 0: Get proxy (if any)\n", color: NSColor.purple)
    let proxy = self.getSystemProxy ()
  //-------- ① We start by checking if the repository did change by reading the last commit value
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 1: repository did change?\n", color: NSColor.purple)
    var possibleAlert : NSAlert? = nil
    let possibleStoredCurrentCommit = getStoredCurrentCommit ()
    let possibleRemoteCurrentCommit = self.getRemoteCurrentCommit (&possibleAlert, proxy)
    if let storedCurrentCommit = possibleStoredCurrentCommit {
      self.mLibraryUpdateLogTextView.appendMessageString ("  Local commit: \(storedCurrentCommit)\n")
    }else{
      self.mLibraryUpdateLogTextView.appendMessageString ("  No local commit\n")
    }
    if let remoteCurrentCommit = possibleRemoteCurrentCommit {
      self.mLibraryUpdateLogTextView.appendMessageString ("  Repository last commit: \(remoteCurrentCommit)\n")
    }
  //-------- ② Now get remote file that describes this commit
    let repositoryFileDictionary : [String : LibraryContentsDescriptor]
    if possibleAlert == nil, let remoteCurrentCommit = possibleRemoteCurrentCommit {
      repositoryFileDictionary = self.phase2_readOrDownloadLibraryFileDictionary (possibleStoredCurrentCommit, remoteCurrentCommit, proxy, &possibleAlert)
    }else{
      repositoryFileDictionary = [String : LibraryContentsDescriptor] ()
    }
  //-------- ③ Read library descriptor file
    let libraryDescriptorFileContents : [String : CanariLibraryFileDescriptor]
    if possibleAlert == nil {
      libraryDescriptorFileContents = phase3_readLibraryDescriptionFileContents ()
    }else{
      libraryDescriptorFileContents = [String : CanariLibraryFileDescriptor] ()
    }
  //-------- ④ Repository contents has been successfully retrieved, then enumerate local system library
    let localFileSet : Set <String>
    if possibleAlert == nil {
      localFileSet = self.phase4_appendLocalFilesToLibraryFileDictionary (&possibleAlert)
    }else{
      localFileSet = Set <String> ()
    }
  //-------- ⑤ Build library operations
    let libraryOperations : [LibraryOperationElement]
    let newLocalDescription : [String : CanariLibraryFileDescriptor]
    if possibleAlert == nil {
      (libraryOperations, newLocalDescription) = self.phase5_buildLibraryOperations (repositoryFileDictionary, localFileSet, libraryDescriptorFileContents, proxy)
    }else{
      libraryOperations = [LibraryOperationElement] ()
      newLocalDescription = [String : CanariLibraryFileDescriptor] ()
    }
  //-------- ⑥ Order out "Check for update" window
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 6: library is up to date ?\n", color: NSColor.purple)
    let ok = possibleAlert == nil
    if inShowWindow {
      if (possibleAlert == nil) && (libraryOperations.count == 0) {
        self.showUpToDateAlertSheetForLibraryUpdateWindow ()
      }else{
        self.hideCheckingForLibraryUpdateWindow ()
      }
    }
  //-------- ⑦ If ok and there are update operations, perform library update
    if ok && (libraryOperations.count != 0) {
      phase7_performLibraryOperations (libraryOperations, newLocalDescription)
    }else{
      if !ok {
        self.mLibraryUpdateLogTextView.appendWarningString ("  Not realized, due to previous errors\n")
      }
      enableItemsAfterCompletion ()
    }
    preferences_mLastSystemLibraryCheckTime_property.setProp (Date ())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enableItemsAfterCompletion () {
    self.mCheckForLibraryUpdatesButton?.isEnabled = true
    appDelegate ()?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func getRemoteCurrentCommit (_ ioPossibleAlert : inout NSAlert?,
                               _ inProxy : [String]) -> Int? {
    if let data = self.getRemoteFileData ("lastCommit.txt", &ioPossibleAlert, inProxy) {
      if let s = String (data: data, encoding: .ascii), let commit = Int (s) {
        return commit
      }else{
        ioPossibleAlert = NSAlert ()
        ioPossibleAlert?.messageText = "Cannot get remote file"
        ioPossibleAlert?.informativeText = "lastCommit.txt file has an invalid contents"
        return nil
      }
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
