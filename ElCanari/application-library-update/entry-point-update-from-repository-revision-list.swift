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
//-------- ① We start by checking if a repository did change using etag
  inLogTextView.appendMessageString ("Phase 1: asking for commit list\n", color: NSColor.purple)
  let query = "object(expression:master) { ... on Commit { history { edges { node { committedDate message oid } } } } }"
  if let dict = runGraphqlQuery (query, proxy, inLogTextView) {
    var ok = true
    if let repository = dict ["repository"] as? [String : Any],
       let object = repository ["object"] as? [String : Any],
       let history = object ["history"] as? [String : Any],
       let edges = history ["edges"] as? [Any] {
      inLogTextView.appendMessageString ("  \(edges.count) commits\n")
      var revisions = [LibraryRevisionDescriptor] ()
      for commit in edges {
        if let nodeDictionary = commit as? [String : Any],
          let commitDictionary = nodeDictionary ["node"] as? [String : Any] {
          let possibleCommitSHA = commitDictionary ["oid"] as? String
          let possibleCommitMessage = commitDictionary ["message"] as? String
          let possibleCommitDateString = (commitDictionary ["committedDate"] as? String)
          let possibleCommitDate = iso8601StringToDate (possibleCommitDateString)
          if let commitDate = possibleCommitDate, let commitSHA = possibleCommitSHA, let commitMessage = possibleCommitMessage {
            revisions.append (LibraryRevisionDescriptor (commitDate, commitSHA, commitMessage))
            inLogTextView.appendMessageString ("  Date '\(commitDate)', sha \(commitSHA), message '\(commitMessage)'\n")
          }else{
            inLogTextView.appendErrorString ("  Invalid commit format\n")
            ok = false
          }
        }else{
          ok = false
        }
      }
      if ok {
        displayRepositoryCommitList (revisions, proxy, inLogTextView)
      }
    }else{
      ok = false
    }
    if !ok {
      let alert = NSAlert ()
      alert.messageText = "Cannot decode server response"
      _ = alert.runModal ()
    }
  }
//--- Enable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
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
                                              _ inLogTextView : NSTextView) {
  gLibraryCommitListController = LibraryCommitListController (revisions, g_Preferences?.mLibraryRevisionListTableView)
  let alert = NSAlert ()
  alert.messageText = "Select Library Revision"
  alert.accessoryView = g_Preferences?.mLibraryRevisionListScrollView
  alert.addButton (withTitle: "Ok")
  alert.addButton (withTitle: "Cancel")
  let response = alert.runModal ()
  if response == .alertFirstButtonReturn, let selectedRow = g_Preferences?.mLibraryRevisionListTableView?.selectedRow {
    let commitSHA = revisions [selectedRow].mCommitSHA
    inLogTextView.appendMessageString ("  Selected commit SHA: \(commitSHA)\n")
    getRepositoryFileList (forCommitSHA: commitSHA, proxy, inLogTextView)
  }
  gLibraryCommitListController?.ebCleanUp ()
  gLibraryCommitListController = nil
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

