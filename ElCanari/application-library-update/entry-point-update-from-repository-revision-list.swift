//
//  get-repository-revision-list.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/01/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

func startLibraryRevisionListOperation (_ inLogTextView : NSTextView) {
  inLogTextView.appendMessageString ("Start getting library revision list\n", color: NSColor.blue)
//--- Disable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = false
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
//-------- Cleat log window
  inLogTextView.clear ()
//-------- ⓪ Get system proxy
  inLogTextView.appendMessageString ("Phase 0: Get proxy (if any)\n", color: NSColor.purple)
  let proxy = getSystemProxy (inLogTextView)
//-------- ① We start by getting the list of all commits
  inLogTextView.appendMessageString ("Phase 1: asking for commit list\n", color: NSColor.purple)
  var possibleAlert : NSAlert? = nil // If not nil, smoething goes wrong
  let revisions = getRepositoryCommitList (&possibleAlert, proxy, inLogTextView)
  let possibleStoredCurrentCommit = getStoredCurrentCommit ()
  let possibleRemoteCurrentCommit : Int?
  if possibleAlert == nil, let commitIndex = displayRepositoryCommitList (revisions, proxy, inLogTextView) {
    possibleRemoteCurrentCommit = commitIndex
  }else{
    possibleRemoteCurrentCommit = nil
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
  if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) {
    libraryDescriptorFileContents = phase3_readLibraryDescriptionFileContents (inLogTextView)
  }else{
    libraryDescriptorFileContents = [String : CanariLibraryFileDescriptor] ()
  }
//-------- ④ Repository contents has been successfully retrieved, then enumerate local system library
  let localFileSet : Set <String>
  if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) {
    localFileSet = phase4_appendLocalFilesToLibraryFileDictionary (inLogTextView, &possibleAlert)
  }else{
    localFileSet = Set <String> ()
  }
//-------- ⑤ Build library operations
  let libraryOperations : [LibraryOperationElement]
  let newLocalDescription : [String : CanariLibraryFileDescriptor]
  if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) {
    (libraryOperations, newLocalDescription) = phase5_buildLibraryOperations (repositoryFileDictionary, localFileSet, libraryDescriptorFileContents, inLogTextView, proxy)
  }else{
    libraryOperations = [LibraryOperationElement] ()
    newLocalDescription = [String : CanariLibraryFileDescriptor] ()
  }
//-------- ⑥ Display "up to date" message ?
  if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) {
    inLogTextView.appendMessageString ("Phase 6: is the library up to date: ", color: NSColor.purple)
    inLogTextView.appendMessageString ("\((libraryOperations.count == 0) ? "yes" : "no")\n")
    if libraryOperations.count == 0 {
      let alert = NSAlert ()
      alert.messageText = "The library is up to date"
      _ = alert.runModal ()
    }
  }
//-------- ⑦ If ok and there are update operations, perform library update
  if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) && (libraryOperations.count != 0) {
    phase7_performLibraryOperations (libraryOperations, newLocalDescription, inLogTextView)
  }else{
    if let alert = possibleAlert {
      _ = alert.runModal ()
    }
    enableItemsAfterCompletion ()
  }
}

//----------------------------------------------------------------------------------------------------------------------

private func getRepositoryCommitList (_ ioPossibleAlert : inout NSAlert?,
                                      _ inProxy : [String],
                                      _ inLogTextView : NSTextView) -> [LibraryRevisionDescriptor] {
  var revisions = [LibraryRevisionDescriptor] ()
//--- Get lastest commit
  let possibleRemoteCurrentCommit = getRemoteCurrentCommit (inLogTextView, &ioPossibleAlert, inProxy)
  if let remoteCurrentCommit = possibleRemoteCurrentCommit {
  //--- Loop for getting commit description
    for i in 1 ... remoteCurrentCommit {
      if let data = getRemoteFileData ("commits/commit-\(i).plist", &ioPossibleAlert, inLogTextView, inProxy) {
        if let possibleDict = try? PropertyListSerialization.propertyList (from: data, format: nil),
           let dict = possibleDict as? [String : Any],
           let commitDate = dict ["date"] as? Date,
           let commitMessage = dict ["message"] as? String {
          revisions.append (LibraryRevisionDescriptor (commitDate, i, commitMessage))
        }else{
          ioPossibleAlert = NSAlert ()
          ioPossibleAlert?.messageText = "Invalid response format for commit \(i)"
          break ;
        }
      }else{
        break ;
      }
    }
  }
//---
  if ioPossibleAlert == nil {
    revisions.reverse () // So last commit becomes the first one
  }else{
    revisions.removeAll ()
  }
  return revisions
}

//----------------------------------------------------------------------------------------------------------------------
//https://stackoverflow.com/questions/39433852/parsing-a-iso8601-string-to-date-in-swift
//----------------------------------------------------------------------------------------------------------------------

private func iso8601StringToDate (_ inString : String?) -> Date? {
  var date : Date? = nil
  if let str = inString {
    let dateFormatter = DateFormatter ()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    date = dateFormatter.date (from: str)
  }
  return date
}

//----------------------------------------------------------------------------------------------------------------------

final class LibraryRevisionDescriptor : EBObject {

  //····················································································································
  //   Properties
  //····················································································································

  let mDate : Date
  let mCommitIndex : Int
  let mMessage : String

  //····················································································································
  //   init
  //····················································································································

  init (_ date : Date, _ commitIndex : Int, _ message : String) {
    mDate = date
    mCommitIndex = commitIndex
    mMessage = message
  }

  //····················································································································

  @objc dynamic var message : String { return self.mMessage }

  //····················································································································

  @objc dynamic var commit : String { return "\(self.mCommitIndex)" }

  //····················································································································

  @objc dynamic var date : String {
    let formatter = DateFormatter ()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter.string (from: self.mDate)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

final class LibraryCommitListController : EBObject {

  //····················································································································
  //   Properties
  //····················································································································

  let mRevisions : [LibraryRevisionDescriptor]
  let mArrayController = NSArrayController ()
  let mTableView : Optional <NSTableView>

  //····················································································································
  //   init
  //····················································································································

  init (_ revisions : [LibraryRevisionDescriptor], _ inTableView : NSTableView?) {
    mRevisions = revisions
    mTableView = inTableView
    super.init ()
    if let tableView = inTableView {
      tableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "commit"))?.bind (
        NSBindingName.value,
        to: self.mArrayController,
        withKeyPath: "arrangedObjects.commit",
        options: nil
      )
      tableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "message"))?.bind (
        NSBindingName.value,
        to: self.mArrayController,
        withKeyPath: "arrangedObjects.message",
        options: nil
      )
      tableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "date"))?.bind (
        NSBindingName.value,
        to: self.mArrayController,
        withKeyPath: "arrangedObjects.date",
        options: nil
      )
      self.mArrayController.content = self.mRevisions
    }
  }

  //····················································································································
  //   ebCleanUp
  //····················································································································

  override func ebCleanUp () {
    self.mTableView?.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "commit"))?.unbind (NSBindingName.value)
    self.mTableView?.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "date"))?.unbind (NSBindingName.value)
    self.mTableView?.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "message"))?.unbind (NSBindingName.value)
    self.mArrayController.content = nil
    super.ebCleanUp ()
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

var gLibraryCommitListController : LibraryCommitListController? = nil

//----------------------------------------------------------------------------------------------------------------------

fileprivate func displayRepositoryCommitList (_ revisions : [LibraryRevisionDescriptor],
                                              _ proxy : [String],
                                              _ inLogTextView : NSTextView) -> Int? {
  gLibraryCommitListController = LibraryCommitListController (revisions, g_Preferences?.mLibraryRevisionListTableView)
  let alert = NSAlert ()
  alert.messageText = "Select Library Revision"
  alert.accessoryView = g_Preferences?.mLibraryRevisionListScrollView
  alert.addButton (withTitle: "Ok")
  alert.addButton (withTitle: "Cancel")
  let response = alert.runModal ()
  var result : Int?
  if response == .alertFirstButtonReturn, let selectedRow = g_Preferences?.mLibraryRevisionListTableView?.selectedRow {
    if selectedRow >= 0 {
      let commitIndex = revisions [selectedRow].mCommitIndex
      result = commitIndex
      inLogTextView.appendMessageString ("  Selected commit index from dialog: \(commitIndex)\n")
    }else{
      inLogTextView.appendErrorString ("  Invalid selected row from dialog: \(selectedRow)\n")
      result = nil
    }
  }else{
    inLogTextView.appendMessageString ("  Dialog has been cancelled\n")
    result = nil
  }
  gLibraryCommitListController?.ebCleanUp ()
  gLibraryCommitListController = nil
  return result
}

//----------------------------------------------------------------------------------------------------------------------

