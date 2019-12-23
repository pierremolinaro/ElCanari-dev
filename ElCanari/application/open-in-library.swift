//
//  OpenInLibrary.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class OpenInLibrary : NSObject,
                      NSOutlineViewDataSource, NSOutlineViewDelegate,
                      NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  @IBOutlet private var mDialog : NSWindow? = nil
  @IBOutlet private var mOpenButton : NSButton? = nil
  @IBOutlet private var mCancelButton : NSButton? = nil
  @IBOutlet private var mOutlineView : NSOutlineView? = nil
  @IBOutlet private var mTableView : NSTableView? = nil
  @IBOutlet private var mFullPathTextField : NSTextField? = nil
  @IBOutlet private var mStatusTextField : NSTextField? = nil
  @IBOutlet private var mPartImage : NSImageView? = nil
  @IBOutlet private var mNoSelectedPartTextField : NSTextField? = nil
  @IBOutlet private var mSearchField : NSSearchField? = nil

  //····················································································································
  //   Load document, displayed as sheet
  //····················································································································

  internal func loadDocumentFromLibrary (windowForSheet inWindow : NSWindow,
                                         alreadyLoadedDocuments inNames : Set <String>,
                                         callBack : @escaping (_ inData : Data, _ inName : String) -> Void,
                                         postAction : Optional <() -> Void>) {
  //--- Configure
    self.mFullPathTextField?.stringValue = ""
    self.mStatusTextField?.stringValue = ""
    self.mCancelButton?.target = self
    self.mCancelButton?.action = #selector (OpenInLibrary.abortSheetAction (_:))
    self.mOpenButton?.target = self
    self.mOpenButton?.action = #selector (OpenInLibrary.stopSheetAction (_:))
    self.mOpenButton?.isEnabled = false
    self.mPartImage?.image = nil
    self.mNoSelectedPartTextField?.isHidden = false
    self.mOutlineView?.dataSource = self
    self.mOutlineView?.delegate = self
    self.mTableView?.dataSource = self
    self.mTableView?.delegate = self
    self.buildDataSource (alreadyLoadedDocuments: inNames)
    self.mOutlineView?.reloadData ()
    self.mTableView?.reloadData ()
  //--- Dialog
    if let dialog = self.mDialog {
      inWindow.beginSheet (dialog) { (_ inModalResponse : NSApplication.ModalResponse) in
        if inModalResponse == .stop,
             let selectedRow = self.mOutlineView?.selectedRow,
             let selectedItem = self.mOutlineView?.item (atRow: selectedRow) as? OpenInLibraryDialogItem,
             selectedItem.mFullPath != "" {
          let fm = FileManager ()
          if let data = fm.contents (atPath: selectedItem.mFullPath) {
            callBack (data, selectedItem.mFullPath.lastPathComponent.deletingPathExtension)
            postAction? ()
          }
        }
//        self.mOutlineViewDataSource = []
//        self.mOutlineView?.reloadData ()
      }
    }
  }

  //····················································································································

  @objc private func abortSheetAction (_ inSender : Any?) {
    if let myWindow = self.mDialog, let parent = myWindow.sheetParent {
      parent.endSheet (myWindow, returnCode: .abort)
    }
  }

  //····················································································································

  @objc private func stopSheetAction (_ inSender : Any?) {
    if let myWindow = self.mDialog, let parent = myWindow.sheetParent {
      parent.endSheet (myWindow, returnCode: .stop)
    }
  }

  //····················································································································
  //   Open document in library, displayed as dialog window
  //····················································································································

  internal func openDocumentInLibrary (windowTitle inTitle : String) {
  //--- Configure
    self.mDialog?.title = inTitle
    self.mFullPathTextField?.stringValue = ""
    self.mStatusTextField?.stringValue = ""
    self.mCancelButton?.target = self
    self.mCancelButton?.action = #selector (self.abortModalAction (_:))
    self.mOpenButton?.target = self
    self.mOpenButton?.action = #selector (self.stopModalAndOpenDocumentAction (_:))
    self.mOpenButton?.isEnabled = false
    self.mSearchField?.target = self
    self.mSearchField?.action = #selector (self.searchFieldAction (_:))
    self.mPartImage?.image = nil
    self.mNoSelectedPartTextField?.isHidden = false
    self.mOutlineView?.dataSource = self
    self.mOutlineView?.delegate = self
    self.mTableView?.dataSource = self
    self.mTableView?.delegate = self
    self.buildDataSource (alreadyLoadedDocuments: [])
  //--- Dialog
    if let dialog = self.mDialog {
      _ = NSApp.runModal (for: dialog)
    }
  }

  //····················································································································

  @objc private func removeAllEntries () {
    self.mOutlineViewDataSource = []
    self.mOutlineViewFilteredDataSource = []
    self.mOutlineView?.reloadData ()
    self.mTableViewFilteredDataSource = []
    self.mTableView?.reloadData ()
    self.mOutlineViewSelectedItem = nil
  }

  //····················································································································

  @objc private func abortModalAction (_ inSender : Any?) {
    NSApp.abortModal ()
    self.mDialog?.orderOut (nil)
    self.removeAllEntries ()
  }

  //····················································································································

  @objc private func stopModalAndOpenDocumentAction (_ inSender : Any?) {
    NSApp.stopModal ()
    self.mDialog?.orderOut (nil)
    if let selectedRow = self.mOutlineView?.selectedRow,
       let selectedItem = self.mOutlineView?.item (atRow: selectedRow) as? OpenInLibraryDialogItem,
       selectedItem.mFullPath != "" {
      let dc = NSDocumentController.shared
      let url = URL (fileURLWithPath: selectedItem.mFullPath)
      dc.openDocument (withContentsOf: url, display: true) { (document : NSDocument?, alreadyOpen : Bool, error : Error?) in }
    }
    self.removeAllEntries ()
  }

  //····················································································································
  //   NSOutlineViewDataSource methods
  //····················································································································

  private var mOutlineViewDataSource = [OpenInLibraryDialogItem] ()
  private var mOutlineViewFilteredDataSource = [OpenInLibraryDialogItem] ()

  //····················································································································

  func outlineView (_ outlineView : NSOutlineView, numberOfChildrenOfItem item : Any?) -> Int {
    if let dialogItem = item as? OpenInLibraryDialogItem {
      return dialogItem.mChildren.count
    }else{
      return self.mOutlineViewFilteredDataSource.count
    }
  }

  //····················································································································

  func outlineView (_ outlineView : NSOutlineView, child index : Int, ofItem item : Any?) -> Any {
    if let dialogItem = item as? OpenInLibraryDialogItem {
      return dialogItem.mChildren [index]
    }else{
      return self.mOutlineViewFilteredDataSource [index]
    }
  }

  //····················································································································

  func outlineView (_ outlineView : NSOutlineView, isItemExpandable item : Any) -> Bool {
    if let dialogItem = item as? OpenInLibraryDialogItem {
      return dialogItem.mChildren.count > 0
    }else{
      return false
    }
  }

  //····················································································································
  //   NSOutlineViewDelegate
  //····················································································································

  func outlineView (_ outlineView : NSOutlineView, viewFor inTableColumn : NSTableColumn?, item: Any) -> NSView? {
    var view: NSTableCellView? = nil
    if let dialogItem = item as? OpenInLibraryDialogItem, let tableColumn = inTableColumn {
      if tableColumn.identifier.rawValue == "name" {
        view = outlineView.makeView (withIdentifier: tableColumn.identifier, owner: self) as? NSTableCellView
        if let textField = view?.textField {
          textField.stringValue = dialogItem.mPartName
        }
      }else if tableColumn.identifier.rawValue == "status" {
        view = outlineView.makeView (withIdentifier: tableColumn.identifier, owner: self) as? NSTableCellView
        if let imageView = view?.imageView {
          imageView.image = dialogItem.statusImage ()
        }
      }
    }
    return view
  }

  //····················································································································

  private var mOutlineViewSelectedItem : OpenInLibraryDialogItem? = nil

  //····················································································································

  func outlineViewSelectionDidChange (_ inNotification : Notification) {
    if let selectedRow = self.mOutlineView?.selectedRow,
       let selectedItem = self.mOutlineView?.item (atRow: selectedRow) as? OpenInLibraryDialogItem {
      self.mFullPathTextField?.stringValue = selectedItem.mFullPath
      self.mStatusTextField?.stringValue = selectedItem.statusString ()
      self.mOpenButton?.isEnabled = (selectedItem.mFullPath != "") && !selectedItem.mIsAlreadyLoaded
      self.mNoSelectedPartTextField?.isHidden = selectedItem.mFullPath != ""
      self.mPartImage?.image = selectedItem.image
      self.mOutlineViewSelectedItem = selectedItem
    }else{
      self.mFullPathTextField?.stringValue = ""
      self.mStatusTextField?.stringValue = ""
      self.mOpenButton?.isEnabled = false
      self.mPartImage?.image = nil
      self.mOutlineViewSelectedItem = nil
    }
  //--- Update table view selection
    if let selectedItem = self.mOutlineViewSelectedItem {
      var idx = 0
      while idx < self.mTableViewFilteredDataSource.count {
        let item = self.mTableViewFilteredDataSource [idx]
        if item == selectedItem {
          self.mTableView?.selectRowIndexes (IndexSet (integer: idx), byExtendingSelection: false)
          self.mTableView?.scrollRowToVisible (idx)
        }
        idx += 1
      }
    }else{
      self.mTableView?.deselectAll (nil)
    }
  }

  //····················································································································

  internal func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) { // Abstract method
  }

  //····················································································································

  internal func partLibraryPathForPath (_ inPath : String) -> String {
    return inPath
  }

  //····················································································································

  internal func buildOutlineViewDataSource (extension inFileExtension : String,
                                            alreadyLoadedDocuments inNames : Set <String>,
                                            _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    do{
      let fm = FileManager ()
    //--- Build part dictionary
      var partCountDictionary = [String : Int] ()
      for path in existingLibraryPathArray () {
        let baseDirectory = self.partLibraryPathForPath (path)
        var isDirectory : ObjCBool = false
        if fm.fileExists (atPath: baseDirectory, isDirectory: &isDirectory), isDirectory.boolValue {
          let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
          for f in files {
            if f.pathExtension == inFileExtension {
              let baseName = f.lastPathComponent.deletingPathExtension
              if let n = partCountDictionary [baseName] {
                partCountDictionary [baseName] = n + 1
              }else{
                partCountDictionary [baseName] = 1
              }
            }
          }
        }
      }
    //--- Build data source arraies
      var outlineViewDataSource = [OpenInLibraryDialogItem] ()
      var tableViewDataSource = [OpenInLibraryDialogItem] ()
      for path in existingLibraryPathArray () {
        let baseDirectory = self.partLibraryPathForPath (path)
        var isDirectory : ObjCBool = false
        if fm.fileExists (atPath: baseDirectory, isDirectory: &isDirectory), isDirectory.boolValue {
          let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
          for f in files {
            if f.pathExtension == inFileExtension {
              let fullpath = baseDirectory + "/" + f
              let baseName = f.lastPathComponent.deletingPathExtension
              let isDuplicated : Bool = (partCountDictionary [baseName] ?? 0) > 1
              let pathAsArray = f.deletingPathExtension.components (separatedBy: "/")
              enterPart (&outlineViewDataSource, &tableViewDataSource, pathAsArray, fullpath, isDuplicated, inNames.contains (baseName), inBuildPreviewShapeFunction)
            }
          }
        }
      }
      outlineViewDataSource.recursiveSortUsingPartName ()
      tableViewDataSource.recursiveSortUsingPartName ()
      self.mOutlineViewDataSource = outlineViewDataSource
      self.searchFieldAction (nil)
    }catch (let error) {
      let alert = NSAlert (error: error)
      _ = alert.runModal ()
    }
  }

  //····················································································································
  //   NSTableViewDataSource methods
  //····················································································································

  private var mTableViewFilteredDataSource = [OpenInLibraryDialogItem] ()

  //····················································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn : NSTableColumn?,
                  row inRowIndex : Int) -> NSView? {
    var view: NSTableCellView? = nil
    let item = self.mTableViewFilteredDataSource [inRowIndex]
    if let tableColumn = inTableColumn {
      if tableColumn.identifier.rawValue == "name" {
        view = tableView.makeView (withIdentifier: tableColumn.identifier, owner: self) as? NSTableCellView
        if let textField = view?.textField {
          textField.stringValue = item.mPartName
        }
      }else if tableColumn.identifier.rawValue == "status" {
        view = tableView.makeView (withIdentifier: tableColumn.identifier, owner: self) as? NSTableCellView
        if let imageView = view?.imageView {
          imageView.image = item.statusImage ()
        }
      }
    }
    return view
  }

  //····················································································································
  //   NSTableViewDataSource protocol
  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mTableViewFilteredDataSource.count
  }

  //····················································································································

  func tableViewSelectionDidChange (_ notification : Notification) {
    var newSelectedItem : OpenInLibraryDialogItem? = nil
    if let selectedRow = self.mTableView?.selectedRow, selectedRow >= 0 {
      newSelectedItem = self.mTableViewFilteredDataSource [selectedRow]
    }
    if self.mOutlineViewSelectedItem !== newSelectedItem {
      self.mOutlineViewSelectedItem = newSelectedItem
      self.searchFieldAction (nil)
    }
  }

  //····················································································································
  //   SEARCH FIELD ACTION
  //····················································································································

  @objc private func searchFieldAction (_ inUnusedSender : Any?) {
    let filter = self.mSearchField!.stringValue
  //--- Save expanded items information
    var expandedItems = Set <String> ()
    for entry in self.mOutlineViewFilteredDataSource {
      entry.enterExpandedItemsInto (&expandedItems, "", self.mOutlineView!)
    }
 //   Swift.print ("expanded \(expandedItems.count)")
  //--- Outline view
    self.mOutlineViewFilteredDataSource = []
    for entry in self.mOutlineViewDataSource {
      if let newEntry = entry.filteredBy (filter) {
        self.mOutlineViewFilteredDataSource.append (newEntry)
      }
    }
  //--- Table view
    self.mTableViewFilteredDataSource = []
    for entry in self.mOutlineViewDataSource {
      entry.enterItemFilteredBy (filter, &self.mTableViewFilteredDataSource)
    }
    self.mOutlineView?.reloadData ()
    self.mTableView?.reloadData ()
  //--- Restore table view selection
    if let outlineViewSelectedItem = self.mOutlineViewSelectedItem {
      var newSelectedItem : OpenInLibraryDialogItem? = nil
      for entry in self.mTableViewFilteredDataSource {
        newSelectedItem = entry.findItemEquivalentTo (outlineViewSelectedItem)
        if newSelectedItem != nil {
          break
        }
      }
      self.mOutlineViewSelectedItem = newSelectedItem
    }
  //--- Restore outline view expanded information
    var rowIndex = 0
    for entry in self.mOutlineViewFilteredDataSource {
      entry.restoreExpandedItems (expandedItems, "", &rowIndex, self.mOutlineView!, self.mOutlineViewSelectedItem)
      rowIndex += 1
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func enterPart (_ outlineViewDataSource : inout [OpenInLibraryDialogItem],
                            _ tableViewDataSource : inout [OpenInLibraryDialogItem],
                            _ inPathAsArray : [String],
                            _ inFullpath : String,
                            _ inIsDuplicated : Bool,
                            _ inIsAlreadyLoaded : Bool,
        _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
  if inPathAsArray.count == 1 {
    outlineViewDataSource.append (OpenInLibraryDialogItem (inPathAsArray [0], inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction))
    tableViewDataSource.append (OpenInLibraryDialogItem (inPathAsArray [0], inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction))
  }else{
    var idx = 0
    var found = false
    while (idx < outlineViewDataSource.count) && !found {
      found = outlineViewDataSource [idx].mPartName == inPathAsArray [0]
      if !found {
        idx += 1
      }
    }
    if !found {
      outlineViewDataSource.append (OpenInLibraryDialogItem (inPathAsArray [0], "", false, inIsAlreadyLoaded, inBuildPreviewShapeFunction))
    }
    var pathAsArray = inPathAsArray
    pathAsArray.remove (at: 0)
    enterPart (&outlineViewDataSource [idx].mChildren, &tableViewDataSource, pathAsArray, inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == OpenInLibraryDialogItem {

  //····················································································································

  mutating func recursiveSortUsingPartName () {
    self.sort { $0.mPartName < $1.mPartName }
    for entry in self {
      entry.mChildren.recursiveSortUsingPartName ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class OpenInLibraryDialogItem : EBObject {

  var mChildren = [OpenInLibraryDialogItem] ()
  let mPartName : String
  let mIsDuplicated : Bool
  let mIsAlreadyLoaded : Bool
  let mFullPath : String
  private var mPartStatus : MetadataStatus? = nil
  private var mObjectImage : NSImage? = nil
  private var mBuildPreviewShapeFunction : (_ inRootObject : EBManagedObject?) -> NSImage?

  //····················································································································

  init (_ inPartName : String,
        _ inFullPath : String,
        _ inIsDuplicated : Bool,
        _ inIsAlreadyLoaded : Bool,
        _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    mPartName = inPartName
    mFullPath = inFullPath
    mIsDuplicated = inIsDuplicated
    mIsAlreadyLoaded = inIsAlreadyLoaded
    mBuildPreviewShapeFunction = inBuildPreviewShapeFunction
    super.init ()
  }

  //····················································································································

  func statusString () -> String {
    if self.mFullPath == "" {
      return ""
    }else if self.mIsAlreadyLoaded {
      return "Already loaded"
    }else if self.mIsDuplicated {
      return "Duplicated"
    }else{
      switch self.partStatus {
      case .unknown :
        return "Unknown"
      case .ok :
        return "Ok"
      case .error :
        return "This part has error(s)"
      case .warning :
        return "This part has warning(s)"
      }
    }
  }

  //····················································································································

  func statusImage () -> NSImage? {
    if self.mFullPath == "" {
      return nil
    }else if self.mIsDuplicated || self.mIsAlreadyLoaded {
      return NSImage (named: NSImage.Name ("NSStatusUnavailable"))
    }else{
      switch self.partStatus {
      case .unknown :
        return NSImage (named: NSImage.Name ("NSStatusNone"))
      case .ok :
        return NSImage (named: NSImage.Name ("NSStatusAvailable"))
      case .error :
        return NSImage (named: NSImage.Name ("NSStatusUnavailable"))
      case .warning :
        return NSImage (named: NSImage.Name ("NSStatusPartiallyAvailable"))
      }
    }
  }

  //····················································································································

  var partStatus : MetadataStatus {
    var status = MetadataStatus.unknown
    if let s = self.mPartStatus {
      status = s
    }else if self.mFullPath != "" {
      (status, _) = try! metadataForFileAtPath (self.mFullPath)
    }
    self.mPartStatus = status
    return status
  }

 //····················································································································

  var image : NSImage {
    if let image = self.mObjectImage {
      return image
    }else{
      let image = self.buildImage ()
      self.mObjectImage = image
      return image
    }
  }

  //····················································································································

  private func buildImage () -> NSImage {
    var image : NSImage? = nil
    let fm = FileManager ()
    if let data = fm.contents (atPath: self.mFullPath) {
      do{
        let (_, _, rootObject) = try loadEasyBindingFile (nil, from: data)
        image = self.mBuildPreviewShapeFunction (rootObject)
      }catch let error {
        let alert = NSAlert (error: error)
        _ = alert.runModal ()
      }
    }
    return image ?? NSImage ()
  }

  //····················································································································

  func filteredBy (_ inFilter : String) -> OpenInLibraryDialogItem? {
    if self.mFullPath == "" {
      var children = [OpenInLibraryDialogItem] ()
      for entry in self.mChildren {
        if let newEntry = entry.filteredBy (inFilter) {
          children.append (newEntry)
        }
      }
      if children.count > 0 {
        let result = OpenInLibraryDialogItem (
          self.mPartName,
          self.mFullPath,
          self.mIsDuplicated,
          self.mIsAlreadyLoaded,
          self.mBuildPreviewShapeFunction
        )
        result.mChildren = children
        return result
      }else{
        return nil
      }
    }else if (inFilter == "") || self.mPartName.contains (inFilter) {
      return self
    }else{
      return nil
    }
  }

  //····················································································································

  func findItemEquivalentTo (_ inItem : OpenInLibraryDialogItem) -> OpenInLibraryDialogItem? {
    if (self.mPartName == inItem.mPartName) && (self.mFullPath == inItem.mFullPath) {
      return self
    }else{
      for entry in self.mChildren {
        if let equivalentEntry = entry.findItemEquivalentTo (inItem) {
          return equivalentEntry
        }
      }
      return nil
    }
  }

  //····················································································································

  func enterItemFilteredBy (_ inFilter : String, _ ioArray : inout [OpenInLibraryDialogItem]) {
    if self.mFullPath == "" {
       for entry in self.mChildren {
         entry.enterItemFilteredBy (inFilter, &ioArray)
       }
     }else if (inFilter == "") || self.mPartName.contains (inFilter) {
       ioArray.append (self)
     }
  }

  //····················································································································

  func enterExpandedItemsInto (_ ioExpandedPathSet : inout Set <String>, _ inPath : String, _ inOutlineView : NSOutlineView) {
    let path = inPath + "/" + self.mPartName
    if inOutlineView.isItemExpanded (self) {
      ioExpandedPathSet.insert (path)
    }
    for entry in self.mChildren {
      entry.enterExpandedItemsInto (&ioExpandedPathSet, path, inOutlineView)
    }
  }

  //····················································································································

  func restoreExpandedItems (_ inExpandedPathSet : Set <String>,
                             _ inPath : String,
                             _ ioRowIndex : inout Int,
                             _ inOutlineView : NSOutlineView,
                             _ inOptionalSelectedItem : OpenInLibraryDialogItem?) {
    let path = inPath + "/" + self.mPartName
    if (self.mPartName == inOptionalSelectedItem?.mPartName) && (self.mFullPath == inOptionalSelectedItem?.mFullPath) {
      inOutlineView.selectRowIndexes (IndexSet (integer: ioRowIndex), byExtendingSelection: false)
    }
    if inExpandedPathSet.contains (path) {
      inOutlineView.expandItem (self)
      ioRowIndex += 1
    }
    for entry in self.mChildren {
      entry.restoreExpandedItems (inExpandedPathSet, path, &ioRowIndex, inOutlineView, inOptionalSelectedItem)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
