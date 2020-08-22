//
//  OpenInLibrary.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class OpenInLibrary : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  @IBOutlet private var mDialog : NSWindow? = nil
  @IBOutlet private var mOpenButton : NSButton? = nil
  @IBOutlet private var mCancelButton : NSButton? = nil
  @IBOutlet private var mTableView : NSTableView? = nil
  @IBOutlet private var mFullPathTextField : NSTextField? = nil
  @IBOutlet private var mStatusTextField : NSTextField? = nil
  @IBOutlet private var mPartImage : NSImageView? = nil
  @IBOutlet private var mNoSelectedPartTextField : NSTextField? = nil
  @IBOutlet private var mSearchField : NSSearchField? = nil

  //····················································································································

  private func configureWith (alreadyLoadedDocuments inNames : Set <String>) {
    self.mFullPathTextField?.stringValue = ""
    self.mStatusTextField?.stringValue = ""
    self.mCancelButton?.target = self
    self.mOpenButton?.target = self
    self.mOpenButton?.isEnabled = false
    self.mSearchField?.target = self
    self.mSearchField?.action = #selector (self.searchFieldAction (_:))
    self.mPartImage?.image = nil
    self.mNoSelectedPartTextField?.isHidden = false
    self.mTableView?.dataSource = self
    self.mTableView?.delegate = self
    self.buildDataSource (alreadyLoadedDocuments: inNames)
    self.mTableView?.reloadData ()
  //--- Set sort descriptors
    if let column = self.mTableView?.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "name")) {
      let sd = NSSortDescriptor (key: "name", ascending: true)
      column.sortDescriptorPrototype = sd
      self.mTableView?.sortDescriptors = [sd]
    }
  }

  //····················································································································
  //   Load document, displayed as sheet
  //····················································································································

  internal func loadDocumentFromLibrary (windowForSheet inWindow : NSWindow,
                                         alreadyLoadedDocuments inNames : Set <String>,
                                         callBack : @escaping (_ inData : Data, _ inName : String) -> Void,
                                         postAction : Optional <() -> Void>) {
  //--- Configure
    self.configureWith (alreadyLoadedDocuments: inNames)
    self.mOpenButton?.action = #selector (self.stopSheetAction)
    self.mCancelButton?.action = #selector (self.abortSheetAction)
  //--- Dialog
    if let dialog = self.mDialog {
      inWindow.beginSheet (dialog) { (_ inModalResponse : NSApplication.ModalResponse) in
        if inModalResponse == .stop, let selectedRow = self.mTableView?.selectedRow, selectedRow >= 0 {
          let selectedItem = self.mTableViewFilteredDataSource [selectedRow]
          if selectedItem.mFullPath != "" {
            let fm = FileManager ()
            if let data = fm.contents (atPath: selectedItem.mFullPath) {
              callBack (data, selectedItem.mFullPath.lastPathComponent.deletingPathExtension)
              postAction? ()
            }
          }
        }
        self.removeAllEntries ()
      }
    }
  }

  //····················································································································

  @objc private func abortSheetAction (_ inSender : Any?) {
    if let dialog = self.mDialog, let parent = dialog.sheetParent {
      parent.endSheet (dialog, returnCode: .abort)
    }
  }

  //····················································································································

  @objc private func stopSheetAction (_ inSender : Any?) {
    if let dialog = self.mDialog, let parent = dialog.sheetParent {
      parent.endSheet (dialog, returnCode: .stop)
    }
  }

  //····················································································································
  //   Open document in library, displayed as dialog window
  //····················································································································

  internal func openDocumentInLibrary (windowTitle inTitle : String) {
  //--- Configure
    self.mDialog?.title = inTitle
    self.configureWith (alreadyLoadedDocuments: [])
    self.mOpenButton?.action = #selector (self.stopModalAndOpenDocumentAction (_:))
    self.mCancelButton?.action = #selector (self.abortModalAction (_:))
  //--- Dialog
    if let dialog = self.mDialog {
      _ = NSApp.runModal (for: dialog)
    }
  }

  //····················································································································

  @objc private func removeAllEntries () {
    self.mTableViewDataSource = []
    self.mTableViewFilteredDataSource = []
    self.mTableView?.reloadData ()
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
    if let selectedRow = self.mTableView?.selectedRow, selectedRow >= 0 {
      let selectedItem = self.mTableViewFilteredDataSource [selectedRow]
      if selectedItem.mFullPath != "" {
        let dc = NSDocumentController.shared
        let url = URL (fileURLWithPath: selectedItem.mFullPath)
        dc.openDocument (withContentsOf: url, display: true) { (document : NSDocument?, alreadyOpen : Bool, error : Error?) in }
      }
    }
    self.removeAllEntries ()
  }

  //····················································································································

  internal func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) { // Abstract method
  }

  //····················································································································

  internal func partLibraryPathForPath (_ inPath : String) -> String {
    return inPath
  }

  //····················································································································

  internal func buildTableViewDataSource (extension inFileExtension : String,
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
              enterPart (&tableViewDataSource, pathAsArray, fullpath, isDuplicated, inNames.contains (baseName), inBuildPreviewShapeFunction)
            }
          }
        }
      }
      self.mTableViewDataSource = tableViewDataSource
      self.searchFieldAction (nil)
    }catch (let error) {
      let alert = NSAlert (error: error)
      _ = alert.runModal ()
    }
  }

  //····················································································································
  //   NSTableViewDataSource methods
  //····················································································································

  private var mTableViewDataSource = [OpenInLibraryDialogItem] ()
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

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mTableViewFilteredDataSource.count
  }

  //····················································································································

  func tableViewSelectionDidChange (_ notification : Notification) {
    if let selectedRow = self.mTableView?.selectedRow, selectedRow >= 0 {
      let selectedItem = self.mTableViewFilteredDataSource [selectedRow]
      self.mFullPathTextField?.stringValue = selectedItem.mFullPath
      self.mStatusTextField?.stringValue = selectedItem.statusString ()
      self.mOpenButton?.isEnabled = (selectedItem.mFullPath != "") && !selectedItem.mIsAlreadyLoaded
      self.mNoSelectedPartTextField?.isHidden = selectedItem.mFullPath != ""
      self.mPartImage?.image = selectedItem.image
    }else{
      self.mFullPathTextField?.stringValue = ""
      self.mStatusTextField?.stringValue = ""
      self.mOpenButton?.isEnabled = false
      self.mPartImage?.image = nil
    }
  }

  //····················································································································
  //    T A B L E V I E W    S O U R C E : tableView:sortDescriptorsDidChange:
  //····················································································································

  func tableView (_ tableView : NSTableView, sortDescriptorsDidChange oldDescriptors : [NSSortDescriptor]) {
    self.searchFieldAction (nil)
  }

  //····················································································································
  //   SEARCH FIELD ACTION
  //····················································································································

  @objc private func searchFieldAction (_ inUnusedSender : Any?) {
    let filter = self.mSearchField!.stringValue.uppercased ()
  //--- Save selected item information
    let optionalSelectedItem : OpenInLibraryDialogItem?
    if let selectedRow = self.mTableView?.selectedRow, selectedRow >= 0 {
      optionalSelectedItem = self.mTableViewFilteredDataSource [selectedRow]
    }else{
      optionalSelectedItem = nil
    }
  //--- Table view
    if filter == "" {
      self.mTableViewFilteredDataSource = self.mTableViewDataSource
    }else{
      self.mTableViewFilteredDataSource = []
      for entry in self.mTableViewDataSource {
        if entry.mPartName.uppercased ().contains (filter) {
          self.mTableViewFilteredDataSource.append (entry)
        }
      }
    }
    self.mTableViewFilteredDataSource.sort { $0.mPartName < $1.mPartName }
    if let sortDescriptors = self.mTableView?.sortDescriptors {
      for sortDescriptor in sortDescriptors {
        if (sortDescriptor.key == "name") && !sortDescriptor.ascending {
          self.mTableViewFilteredDataSource.reverse ()
        }
      }
    }
    self.mTableView?.reloadData ()
  //--- Restore table view selection
    var hasSelection = false
    if let selectedItem = optionalSelectedItem {
      var rowIndex = 0
      for entry in self.mTableViewFilteredDataSource {
        if entry === selectedItem {
          self.mTableView?.selectRowIndexes (IndexSet (integer: rowIndex), byExtendingSelection: false)
          self.mTableView?.scrollRowToVisible (rowIndex)
          hasSelection = true
          break
        }
        rowIndex += 1
      }
    }
    if !hasSelection {
      self.mTableView?.deselectAll (nil)
      self.mFullPathTextField?.stringValue = ""
      self.mStatusTextField?.stringValue = ""
      self.mOpenButton?.isEnabled = false
      self.mPartImage?.image = nil
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func enterPart (_ tableViewDataSource : inout [OpenInLibraryDialogItem],
                            _ inPathAsArray : [String],
                            _ inFullpath : String,
                            _ inIsDuplicated : Bool,
                            _ inIsAlreadyLoaded : Bool,
        _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
  if inPathAsArray.count == 1 {
    tableViewDataSource.append (OpenInLibraryDialogItem (inPathAsArray [0], inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction))
  }else{
    var pathAsArray = inPathAsArray
    pathAsArray.remove (at: 0)
    enterPart (&tableViewDataSource, pathAsArray, inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class OpenInLibraryDialogItem : EBObject {

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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
