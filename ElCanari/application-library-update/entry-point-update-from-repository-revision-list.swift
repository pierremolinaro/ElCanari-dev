//
//  get-repository-revision-list.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryRevisionListOperation (_ inLogTextView : AutoLayoutStaticTextView) {
  inLogTextView.appendMessageString ("Start getting library revision list\n", color: NSColor.blue)
//--- Disable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = false
  gApplicationDelegate?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
//-------- Cleat log window
  inLogTextView.clear ()
//-------- ⓪ Get system proxy
  inLogTextView.appendMessageString ("Phase 0: Get proxy (if any)\n", color: NSColor.purple)
  let proxy = getSystemProxy (inLogTextView)
//-------- ① We start by getting the list of all commits
  inLogTextView.appendMessageString ("Phase 1: asking for commit list\n", color: NSColor.purple)
  var possibleAlert : NSAlert? = nil // If not nil, something goes wrong
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCommitList (_ ioPossibleAlert : inout NSAlert?,
                                      _ inProxy : [String],
                                      _ inLogTextView : AutoLayoutStaticTextView) -> [LibraryRevisionDescriptor] {
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

final class LibraryRevisionDescriptor : EBObjcBaseObject { // SHOULD INHERIT FROM NSObject

  //····················································································································
  //   Properties
  //····················································································································

  let mDateString : String
  let mCommitIndex : Int
  let mMessage : String

  //····················································································································
  //   init
  //····················································································································

  init (_ inDate : Date, _ commitIndex : Int, _ message : String) {
    let formatter = DateFormatter ()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    self.mDateString = formatter.string (from: inDate)
    self.mCommitIndex = commitIndex
    self.mMessage = message
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class LibraryCommitListController : EBObjcBaseObject, AutoLayoutTableViewDelegate {

  //····················································································································
  //   Properties
  //····················································································································

  let mRevisions : [LibraryRevisionDescriptor]
  let mTableView : AutoLayoutTableView

  //····················································································································
  //   init
  //····················································································································

  init (_ inRevisions : [LibraryRevisionDescriptor]) {
    self.mRevisions = inRevisions
    self.mTableView = AutoLayoutTableView (size: .regular, addControlButtons: false)
    super.init ()
  //--- Configure tableview
    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mRevisions.count ?? 0 },
      delegate: self
    )
    self.mTableView.addColumn_Int (
      valueGetterDelegate: { [weak self] in self?.mRevisions [$0].mCommitIndex },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Commit",
      minWidth: 50,
      maxWidth: 50,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in self?.mRevisions [$0].mDateString },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Date",
      minWidth: 150,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in self?.mRevisions [$0].mMessage },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Titre",
      minWidth: 200,
      maxWidth: 500,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.sortAndReloadData ()
  }

  //····················································································································
  //   AutoLayoutTableViewDelegate
  //····················································································································

  func tableViewSelectionDidChange (selectedRows inSelectedRows: IndexSet) {
  }

  func indexesOfSelectedObjects() -> IndexSet {
    return IndexSet ()
  }

  func addEntry () {
  }

  func removeSelectedEntries() {
  }

  func beginSorting() {
  }

  func endSorting () {
  }

  //····················································································································

  func dialog (_ inLogTextView : AutoLayoutStaticTextView) -> Int? {
  //--- Build Panel
    let panel = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 600, height: 300),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: false
    )
    panel.title = "Library Update"
    panel.hasShadow = true
  //--- Main view
    let mainView = AutoLayoutVerticalStackView ().set (margins: 20)
  //--- Informative text
    let informativeText = AutoLayoutLabel (bold: false, size: .regular).set (alignment: .center).expandableWidth ()
    informativeText.stringValue = "Select Library Revision"
    mainView.appendView (informativeText)
  //--- Table view
    mainView.appendView (self.mTableView)
  //--- Last line
    let lastLine = AutoLayoutHorizontalStackView ()
    lastLine.appendFlexibleSpace ()
    let cancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: panel, isInitialFirstResponder: false)
    lastLine.appendView (cancelButton)
    let upDateButton = AutoLayoutSheetDefaultOkButton (title: "Update", size: .regular, sheet: panel, isInitialFirstResponder: true)
    lastLine.appendView (upDateButton)
    mainView.appendView (lastLine)
  //--- Set autolayout view to panel
    panel.contentView = AutoLayoutViewByPrefixingAppIcon (prefixedView: AutoLayoutWindowContentView (view: mainView))
  //--- Run modal
    DispatchQueue.main.async { self.mTableView.scrollRowToVisible (row: 0) }
    let response = NSApp.runModal (for: panel)
  //--- response
    if response == .stop {
      return self.mRevisions [self.mTableView.selectedRow].mCommitIndex
    }else{
      return nil
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func displayRepositoryCommitList (_ revisions : [LibraryRevisionDescriptor],
                                              _ proxy : [String],
                                              _ inLogTextView : AutoLayoutStaticTextView) -> Int? {
  let libraryCommitListController = LibraryCommitListController (revisions)
  let result = libraryCommitListController.dialog (inLogTextView)
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

