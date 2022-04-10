
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let CURL = "/usr/bin/curl"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   LIBRARY UPDATE ENTRY POINT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdateOperation (showProgressWindow inShowWindow : Bool, _ inLogTextView : AutoLayoutStaticTextView) {
  inLogTextView.appendMessageString ("Start library update operation\n", color: NSColor.blue)
//--- Disable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = false
  gApplicationDelegate?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
//-------- Cleat log window
  inLogTextView.clear ()
//-------- Show "Check for update" window
  if inShowWindow {
    g_Preferences?.showCheckingForLibraryUpdateWindow ()
  }
//-------- ⓪ Get system proxy
  inLogTextView.appendMessageString ("Phase 0: Get proxy (if any)\n", color: NSColor.purple)
  let proxy = getSystemProxy (inLogTextView)
//-------- ① We start by checking if the repository did change by reading the last commit value
  inLogTextView.appendMessageString ("Phase 1: repository did change?\n", color: NSColor.purple)
  var possibleAlert : NSAlert? = nil
  let possibleStoredCurrentCommit = getStoredCurrentCommit ()
  let possibleRemoteCurrentCommit = getRemoteCurrentCommit (inLogTextView, &possibleAlert, proxy)
  if let storedCurrentCommit = possibleStoredCurrentCommit {
    inLogTextView.appendMessageString ("  Local commit: \(storedCurrentCommit)\n")
  }else{
    inLogTextView.appendMessageString ("  No local commit\n")
  }
  if let remoteCurrentCommit = possibleRemoteCurrentCommit {
    inLogTextView.appendMessageString ("  Repository last commit: \(remoteCurrentCommit)\n")
  }
//-------- ② Now get remote file that describes this commit
  let repositoryFileDictionary : [String : LibraryContentsDescriptor]
  if possibleAlert == nil, let remoteCurrentCommit = possibleRemoteCurrentCommit {
    repositoryFileDictionary = phase2_readOrDownloadLibraryFileDictionary (possibleStoredCurrentCommit, remoteCurrentCommit, inLogTextView, proxy, &possibleAlert)
  }else{
    repositoryFileDictionary = [String : LibraryContentsDescriptor] ()
  }
//-------- ③ Read library descriptor file
  let libraryDescriptorFileContents : [String : CanariLibraryFileDescriptor]
  if possibleAlert == nil {
    libraryDescriptorFileContents = phase3_readLibraryDescriptionFileContents (inLogTextView)
  }else{
    libraryDescriptorFileContents = [String : CanariLibraryFileDescriptor] ()
  }
//-------- ④ Repository contents has been successfully retrieved, then enumerate local system library
  let localFileSet : Set <String>
  if possibleAlert == nil {
    localFileSet = phase4_appendLocalFilesToLibraryFileDictionary (inLogTextView, &possibleAlert)
  }else{
    localFileSet = Set <String> ()
  }
//-------- ⑤ Build library operations
  let libraryOperations : [LibraryOperationElement]
  let newLocalDescription : [String : CanariLibraryFileDescriptor]
  if possibleAlert == nil {
    (libraryOperations, newLocalDescription) = phase5_buildLibraryOperations (repositoryFileDictionary, localFileSet, libraryDescriptorFileContents, inLogTextView, proxy)
  }else{
    libraryOperations = [LibraryOperationElement] ()
    newLocalDescription = [String : CanariLibraryFileDescriptor] ()
  }
//-------- ⑥ Order out "Check for update" window
  inLogTextView.appendMessageString ("Phase 6: library is up to date ?\n", color: NSColor.purple)
  let ok = possibleAlert == nil
  if inShowWindow {
    if (possibleAlert == nil) && (libraryOperations.count == 0) {
      g_Preferences?.showUpToDateAlertSheetForLibraryUpdateWindow ()
    }else{
      g_Preferences?.hideCheckingForLibraryUpdateWindow ()
    }
  }
//-------- ⑦ If ok and there are update operations, perform library update
  if ok && (libraryOperations.count != 0) {
    phase7_performLibraryOperations (libraryOperations, newLocalDescription, inLogTextView)
  }else{
    if !ok {
      inLogTextView.appendWarningString ("  Not realized, due to previous errors\n")
    }
    enableItemsAfterCompletion ()
  }
  preferences_mLastSystemLibraryCheckTime = Date ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func enableItemsAfterCompletion () {
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
  gApplicationDelegate?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getRemoteCurrentCommit (_ inLogTextView : AutoLayoutStaticTextView,
                             _ ioPossibleAlert : inout NSAlert?,
                             _ inProxy : [String]) -> Int? {
  if let data = getRemoteFileData ("lastCommit.txt", &ioPossibleAlert, inLogTextView, inProxy) {
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
