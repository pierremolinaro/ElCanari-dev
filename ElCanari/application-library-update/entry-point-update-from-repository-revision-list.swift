//
//  get-repository-revision-list.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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
  var revisions = [LibraryRevisionDescriptor] ()
  getRepositoryCommitList (&revisions, &possibleAlert, proxy, inLogTextView)
  var performUpdate = false
  if possibleAlert == nil {
    if let commitSHA = displayRepositoryCommitList (revisions, proxy, inLogTextView) {
      storeRepositoryCommitSHA_removeETAG (commitSHA)
      performUpdate = true
    }
  }
//-------- ② Repository ETAG and commit SHA have been successfully retrieve,
//            now read of download the file list corresponding to this commit
  let repositoryFileDictionary : [String : LibraryRepositoryFileDescriptor]
  if performUpdate && (possibleAlert == nil) {
    repositoryFileDictionary = phase2_readOrDownloadLibraryFileDictionary (inLogTextView, proxy, &possibleAlert)
  }else{
    repositoryFileDictionary = [String : LibraryRepositoryFileDescriptor] ()
  }
//-------- ③ Read library descriptor file
  let libraryDescriptorFileContents : [String : CanariLibraryFileDescriptor]
  if performUpdate && (possibleAlert == nil) {
    libraryDescriptorFileContents = phase3_readLibraryDescriptionFileContents (inLogTextView)
  }else{
    libraryDescriptorFileContents = [String : CanariLibraryFileDescriptor] ()
  }
//-------- ④ Repository contents has been successfully retrieved, then enumerate local system library
  let localFileSet : Set <String>
  if performUpdate && (possibleAlert == nil) {
    localFileSet = phase4_appendLocalFilesToLibraryFileDictionary (inLogTextView, &possibleAlert)
  }else{
    localFileSet = Set <String> ()
  }
//-------- ⑤ Build library operations
  let libraryOperations : [LibraryOperationElement]
  let newLocalDescription : [String : CanariLibraryFileDescriptor]
  if performUpdate && (possibleAlert == nil) {
    (libraryOperations, newLocalDescription) = phase5_buildLibraryOperations (repositoryFileDictionary, localFileSet, libraryDescriptorFileContents, inLogTextView, proxy)
  }else{
    libraryOperations = [LibraryOperationElement] ()
    newLocalDescription = [String : CanariLibraryFileDescriptor] ()
  }
//-------- ⑥ is the library up to date?
  if performUpdate && (possibleAlert == nil) {
    inLogTextView.appendMessageString ("Phase 6: is the library up to date?\n", color: NSColor.purple)
    if libraryOperations.count == 0 {
      inLogTextView.appendSuccessString ("  The library is up to date\n")
      let alert = NSAlert ()
      alert.messageText = "The library is up to date"
      _ = alert.runModal ()
    }
  }
//-------- ⑦ If ok and there are update operations, perform library update
  if performUpdate && (possibleAlert == nil) && (libraryOperations.count != 0) {
    phase7_performLibraryOperations (libraryOperations, newLocalDescription, inLogTextView)
  }else{
    if let alert = possibleAlert {
      _ = alert.runModal ()
    }
    enableItemsAfterCompletion ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCommitList (_ ioRevisions : inout [LibraryRevisionDescriptor],
                                      _ ioPossibleAlert : inout NSAlert?,
                                      _ inProxy : [String],
                                      _ inLogTextView : NSTextView) {
  let query = "object(expression:master) { ... on Commit { history { edges { node { committedDate message oid } } } } }"
  if let dict = runGraphqlQuery (query, inProxy, &ioPossibleAlert, inLogTextView) {
    var ok = true
    if let repository = dict ["repository"] as? [String : Any],
       let object = repository ["object"] as? [String : Any],
       let history = object ["history"] as? [String : Any],
       let edges = history ["edges"] as? [Any] {
      inLogTextView.appendMessageString ("  \(edges.count) commits\n")
      for commit in edges {
        if let nodeDictionary = commit as? [String : Any],
          let commitDictionary = nodeDictionary ["node"] as? [String : Any] {
          let possibleCommitSHA = commitDictionary ["oid"] as? String
          let possibleCommitMessage = commitDictionary ["message"] as? String
          let possibleCommitDateString = (commitDictionary ["committedDate"] as? String)
          let possibleCommitDate = iso8601StringToDate (possibleCommitDateString)
          if let commitDate = possibleCommitDate, let commitSHA = possibleCommitSHA, let commitMessage = possibleCommitMessage {
            ioRevisions.append (LibraryRevisionDescriptor (commitDate, commitSHA, commitMessage))
            inLogTextView.appendMessageString ("  Date '\(commitDate)', sha \(commitSHA), message '\(commitMessage)'\n")
          }else{
            inLogTextView.appendErrorString ("  Invalid commit format\n")
            ok = false
          }
        }else{
          ok = false
        }
      }
    }else{
      ok = false
    }
    if !ok {
      let alert = NSAlert ()
      alert.messageText = "Cannot decode server response"
      ioPossibleAlert = alert
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//https://stackoverflow.com/questions/39433852/parsing-a-iso8601-string-to-date-in-swift
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func iso8601StringToDate (_ inString : String?) -> Date? {
  var date : Date? = nil
  if let str = inString {
    let dateFormatter = DateFormatter ()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    date = dateFormatter.date (from: str)
  }
  return date
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class LibraryRevisionDescriptor : EBObject {

  //····················································································································
  //   Properties
  //····················································································································

  let mDate : Date
  let mCommitSHA : String
  let mMessage : String

  //····················································································································
  //   init
  //····················································································································

  init (_ date : Date, _ commitSHA : String, _ message : String) {
    mDate = date
    mCommitSHA = commitSHA
    mMessage = message
  }

  //····················································································································

  @objc dynamic var message : String { return self.mMessage }

  //····················································································································

  @objc dynamic var date : String {
    let formatter = DateFormatter ()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter.string (from: self.mDate)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class LibraryCommitListController : EBObject {

  //····················································································································
  //   Properties
  //····················································································································

  let mRevisions : [LibraryRevisionDescriptor]
  var mArrayController = NSArrayController ()
  var mTableView : NSTableView?

  //····················································································································
  //   init
  //····················································································································

  init (_ revisions : [LibraryRevisionDescriptor], _ inTableView : NSTableView?) {
    mRevisions = revisions
    mTableView = inTableView
    super.init ()
    if let tableView = inTableView {
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
    self.mTableView?.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "date"))?.unbind (NSBindingName.value)
    self.mTableView?.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "message"))?.unbind (NSBindingName.value)
    self.mArrayController.content = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

var gLibraryCommitListController : LibraryCommitListController? = nil

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func displayRepositoryCommitList (_ revisions : [LibraryRevisionDescriptor],
                                              _ proxy : [String],
                                              _ inLogTextView : NSTextView) -> String? {
  gLibraryCommitListController = LibraryCommitListController (revisions, g_Preferences?.mLibraryRevisionListTableView)
  let alert = NSAlert ()
  alert.messageText = "Select Library Revision"
  alert.accessoryView = g_Preferences?.mLibraryRevisionListScrollView
  alert.addButton (withTitle: "Ok")
  alert.addButton (withTitle: "Cancel")
  let response = alert.runModal ()
  var result : String?
  if response == .alertFirstButtonReturn, let selectedRow = g_Preferences?.mLibraryRevisionListTableView?.selectedRow {
    let commitSHA = revisions [selectedRow].mCommitSHA
    result = commitSHA
    inLogTextView.appendMessageString ("  Selected commit SHA from dialog: \(commitSHA)\n")
//    getRepositoryFileList (forCommitSHA: commitSHA, proxy, inLogTextView)
  }else{
    inLogTextView.appendMessageString ("  Dialog has been cancelled\n")
    result = nil
  }
  gLibraryCommitListController?.ebCleanUp ()
  gLibraryCommitListController = nil
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

