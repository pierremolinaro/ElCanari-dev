//
//  get-repository-revision-list.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func startLibraryRevisionListOperation () {
    self.mLibraryUpdateLogTextView.appendMessageString ("Start getting library revision list\n", color: NSColor.blue)
  //--- Disable update buttons
    self.mCheckForLibraryUpdatesButton?.isEnabled = false
    appDelegate ()?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
  //-------- Cleat log window
    self.mLibraryUpdateLogTextView.clear ()
  //-------- ⓪ Get system proxy
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 0: Get proxy (if any)\n", color: NSColor.purple)
    let proxy = self.getSystemProxy ()
  //-------- ① We start by getting the list of all commits
    self.mLibraryUpdateLogTextView.appendMessageString ("Phase 1: asking for commit list\n", color: NSColor.purple)
    var possibleAlert : NSAlert? = nil // If not nil, something goes wrong
    let revisions = self.getRepositoryCommitList (&possibleAlert, proxy)
    let possibleStoredCurrentCommit = getStoredCurrentCommit ()
    let possibleRemoteCurrentCommit : Int?
    if possibleAlert == nil, let commitIndex = displayRepositoryCommitList (revisions) {
      possibleRemoteCurrentCommit = commitIndex
    }else{
      possibleRemoteCurrentCommit = nil
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
    if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) {
      libraryDescriptorFileContents = self.phase3_readLibraryDescriptionFileContents ()
    }else{
      libraryDescriptorFileContents = [String : CanariLibraryFileDescriptor] ()
    }
  //-------- ④ Repository contents has been successfully retrieved, then enumerate local system library
    let localFileSet : Set <String>
    if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) {
      localFileSet = self.phase4_appendLocalFilesToLibraryFileDictionary (&possibleAlert)
    }else{
      localFileSet = Set <String> ()
    }
  //-------- ⑤ Build library operations
    let libraryOperations : [LibraryOperationElement]
    let newLocalDescription : [String : CanariLibraryFileDescriptor]
    if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) {
      (libraryOperations, newLocalDescription) = self.phase5_buildLibraryOperations (repositoryFileDictionary, localFileSet, libraryDescriptorFileContents, proxy)
    }else{
      libraryOperations = [LibraryOperationElement] ()
      newLocalDescription = [String : CanariLibraryFileDescriptor] ()
    }
  //-------- ⑥ Display "up to date" message ?
    if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) {
      self.mLibraryUpdateLogTextView.appendMessageString ("Phase 6: is the library up to date: ", color: NSColor.purple)
      self.mLibraryUpdateLogTextView.appendMessageString ("\((libraryOperations.count == 0) ? "yes" : "no")\n")
      if libraryOperations.count == 0 {
        let alert = NSAlert ()
        alert.messageText = "The library is up to date"
        _ = alert.runModal ()
      }
    }
  //-------- ⑦ If ok and there are update operations, perform library update
    if (possibleAlert == nil) && (possibleRemoteCurrentCommit != nil) && (libraryOperations.count != 0) {
      self.phase7_performLibraryOperations (libraryOperations, newLocalDescription)
    }else{
      if let alert = possibleAlert {
        _ = alert.runModal ()
      }
      self.enableItemsAfterCompletion ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func getRepositoryCommitList (_ ioPossibleAlert : inout NSAlert?,
                                        _ inProxy : [String]) -> [LibraryRevisionDescriptor] {
    var revisions = [LibraryRevisionDescriptor] ()
  //--- Get lastest commit
    let possibleRemoteCurrentCommit = self.getRemoteCurrentCommit (&ioPossibleAlert, inProxy)
    if let remoteCurrentCommit = possibleRemoteCurrentCommit {
    //--- Loop for getting commit description
      for i in 1 ... remoteCurrentCommit {
        if let data = self.getRemoteFileData ("commits/commit-\(i).plist", &ioPossibleAlert, inProxy) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor final class LibraryRevisionDescriptor {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mDateString : String
  let mCommitIndex : Int
  let mMessage : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inDate : Date, _ commitIndex : Int, _ message : String) {
    let formatter = DateFormatter ()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    self.mDateString = formatter.string (from: inDate)
    self.mCommitIndex = commitIndex
    self.mMessage = message
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate final class LibraryCommitListController {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mRevisions : [LibraryRevisionDescriptor]
  let mTableView : AutoLayoutTableView

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRevisions : [LibraryRevisionDescriptor]) {
    self.mRevisions = inRevisions
    self.mTableView = AutoLayoutTableView (size: .regular, addControlButtons: false)
  //--- Configure tableview
    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mRevisions.count ?? 0 },
      delegate: nil
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
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func dialog () -> Int? {
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
    _ = mainView.appendView (informativeText)
  //--- Table view
    _ = mainView.appendView (self.mTableView)
  //--- Last line
    let lastLine = AutoLayoutHorizontalStackView ()
    _ = lastLine.appendFlexibleSpace ()
    let cancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular)
    _ = lastLine.appendView (cancelButton)
    let upDateButton = AutoLayoutSheetDefaultOkButton (title: "Update", size: .regular, sheet: panel)
    _ = lastLine.appendView (upDateButton)
    _ = mainView.appendView (lastLine)
  //--- Set autolayout view to panel
    panel.contentView = AutoLayoutViewByPrefixingAppIcon (prefixedView: AutoLayoutWindowContentView (view: mainView))
  //--- Run modal
    DispatchQueue.main.async { self.mTableView.scrollRowToVisible (row: 0) }
    let response = NSApplication.shared.runModal (for: panel)
  //--- response
    if response == .stop {
      return self.mRevisions [self.mTableView.selectedRow].mCommitIndex
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func displayRepositoryCommitList (_ inRevisions : [LibraryRevisionDescriptor]) -> Int? {
  let libraryCommitListController = LibraryCommitListController (inRevisions)
  let result = libraryCommitListController.dialog ()
  return result
}

//--------------------------------------------------------------------------------------------------

