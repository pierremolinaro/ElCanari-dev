//
//  OpenInLibrary.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor class OpenInLibrary : AutoLayoutTableViewDelegate, Sendable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final let mDialog : NSPanel
  private final let mOpenButton : AutoLayoutSheetDefaultOkButton
  private final let mCancelButton : AutoLayoutSheetCancelButton
  private final let mTableView = AutoLayoutTableView (size: .regular, addControlButtons: false)
//  private final let mOutlineView = AutoLayoutOutlineView (size: .regular, addControlButtons: false)
  private final let mStatusTextField = AutoLayoutStaticLabel (title: "", bold: false, size: .regular, alignment: .left)
  private final let mFullPathTextField = AutoLayoutStaticLabel (title: "", bold: false, size: .regular, alignment: .left)
  private final var mPartImage = AutoLayoutImageObserverView (width: 400)
  private final let mNoSelectedPartTextField = AutoLayoutStaticLabel (title: "", bold: true, size: .regular, alignment: .center)
  private final let mNoSelectedPartView = AutoLayoutVerticalStackView ()
  private final let mSearchField = AutoLayoutSearchField (width: 300, size: .regular)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private final let mSegmentedControl = AutoLayoutEnumSegmentedControl (titles: ["Flat", "Hierarchical"], equalWidth: true, size: .regular)
//  private final let mSegmentedControlIndex = EBStoredProperty_Int (defaultValue: 0, undoManager: nil)
//  private final var mSegmentedControlIndexObserver : EBOutletEvent? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mTableViewDataSource = [OpenInLibraryDialogFlatItem] ()
  private final var mTableViewFilteredDataSource = [OpenInLibraryDialogFlatItem] ()

//  private final var mOutlineViewDataSource = [OpenInLibraryDialogHierarchicalItem] ()
//  private final var mOutlineViewFilteredDataSource = [OpenInLibraryDialogHierarchicalItem] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
  //--- Dialog
    self.mDialog = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 700, height: 600),
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )
//    _ = self.mSegmentedControl.bind_selectedIndex (self.mSegmentedControlIndex)
    let mainView = AutoLayoutVerticalStackView ().set (margins: .large)
  //--- First column
//    let tableHStack = AutoLayoutHorizontalStackView ()
//          .appendView (self.mTableView)
//          .appendView (self.mOutlineView)
    let firstColumn = AutoLayoutVerticalStackView ()
          .appendView (self.mSearchField)
          .appendView (self.mTableView)
//          .appendView (self.mSegmentedControl)
//          .appendView (tableHStack)
  //--- Second Column
    _ = self.mNoSelectedPartView.appendFlexibleSpace ()
    _ = self.mNoSelectedPartView.appendViewSurroundedByFlexibleSpaces (self.mNoSelectedPartTextField)
    _ = self.mNoSelectedPartView.appendFlexibleSpace ()
  //---
    let topView = AutoLayoutHorizontalStackView ()
          .appendView (firstColumn)
          .appendView (self.mNoSelectedPartView)
          .appendView (self.mPartImage)
  //--- Add view
    _ = mainView.appendView (topView)
  //--- Grid view: status and path
    let gridView = AutoLayoutGridView2 ()
      .addFirstBaseLineAligned (
        left: AutoLayoutStaticLabel (title: "Status:", bold: false, size: .regular, alignment: .center).notExpandableWidth (),
        right: self.mStatusTextField
      )
      .addFirstBaseLineAligned (
        left: AutoLayoutStaticLabel (title: "Path:", bold: false, size: .regular, alignment: .center),
        right: self.mFullPathTextField
      )
    _ = mainView.appendView (gridView)
  //--- Bottom view
    let bottomView = AutoLayoutHorizontalStackView ()
    self.mCancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular)
    _ = bottomView.appendView (self.mCancelButton)
    _ = bottomView.appendFlexibleSpace ()
    self.mOpenButton = AutoLayoutSheetDefaultOkButton (title: "Open", size: .regular, sheet: self.mDialog)
    _ = bottomView.appendView (self.mOpenButton)
    _ = mainView.appendView (bottomView)
  //--- Set content view
    self.mDialog.contentView = mainView
  //---
//    super.init ()
  //---
//    _ = self.mSearchField.bind_run (target: self, selector: #selector (Self.searchFieldAction (_:)))
    _ = self.mSearchField.setClosureAction { [weak self] in self?.searchFieldAction (nil) }
  //--- Configure table view
    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mTableViewFilteredDataSource.count ?? 0 },
      delegate: self
    )
    self.mTableView.addColumn_NSImage (
      valueGetterDelegate: { [weak self] in self?.mTableViewFilteredDataSource [$0].statusImage () },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Status",
      minWidth: 50,
      maxWidth: 50,
      headerAlignment: .left,
      contentAlignment: .center
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in self?.mTableViewFilteredDataSource [$0].mPartName },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Name",
      minWidth: 250,
      maxWidth: 2_000,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure outline view
//    self.mOutlineView.configure (
//      allowsEmptySelection: false,
//      allowsMultipleSelection: false,
//      rowCountCallBack: { [weak self] in self?.mTableViewFilteredDataSource.count ?? 0 },
//      delegate: self
//    )
//    self.mOutlineView.addColumn_NSImage (
//      valueGetterDelegate: { [weak self] in self?.mTableViewFilteredDataSource [$0].statusImage () },
//      valueSetterDelegate: nil,
//      sortDelegate: nil,
//      title: "Status",
//      minWidth: 50,
//      maxWidth: 50,
//      headerAlignment: .left,
//      contentAlignment: .center
//    )
//    self.mOutlineView.addColumn_String (
//      valueGetterDelegate: { [weak self] in self?.mTableViewFilteredDataSource [$0].mPartName },
//      valueSetterDelegate: nil,
//      sortDelegate: nil,
//      title: "Name",
//      minWidth: 250,
//      maxWidth: 2_000,
//      headerAlignment: .left,
//      contentAlignment: .left
//    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final func configureWith (alreadyLoadedDocuments inNames : Set <String>) {
    self.mNoSelectedPartTextField.stringValue = self.noPartMessage ()
    self.mOpenButton.isEnabled = false
    self.mPartImage.image = nil
    self.mPartImage.isHidden = true
    self.mNoSelectedPartView.isHidden = false
    self.buildDataSource (alreadyLoadedDocuments: inNames)
    self.mTableView.sortAndReloadData ()
//    self.mOutlineView.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Load document, displayed as sheet
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func loadDocumentFromLibrary (windowForSheet inWindow : NSWindow,
                                      alreadyLoadedDocuments inNames : Set <String>,
                                      callBack inCallBack : @MainActor @escaping (_ inData : Data, _ inName : String) -> Bool,
                                      postAction inPostAction : Optional <@MainActor () -> Void>) {
  //--- Configure
    self.configureWith (alreadyLoadedDocuments: inNames)
    _ = self.mOpenButton.setDismissAction ()
  //--- Dialog
    inWindow.beginSheet (self.mDialog) { (_ inModalResponse : NSApplication.ModalResponse) in
      let selectedRow = self.mTableView.selectedRow
      if inModalResponse == .stop, selectedRow >= 0 {
        let selectedItem = self.mTableViewFilteredDataSource [selectedRow]
        if selectedItem.mFullPath != "" {
          let fm = FileManager ()
          if let data = fm.contents (atPath: selectedItem.mFullPath) {
            let ok = inCallBack (data, selectedItem.mFullPath.lastPathComponent.deletingPathExtension)
            if ok {
              inPostAction? ()
            }
          }
        }
      }
      self.removeAllEntries ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Open document in library, displayed as dialog window
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func openDocumentInLibrary (windowTitle inTitle : String) {
  //--- Configure table view and outline view visibility
//    let displayBoth = NSEvent.modifierFlags.contains (.option)
//    if displayBoth {
//      self.mSegmentedControl.isHidden = true
//      self.mSegmentedControlIndexObserver = nil
//      self.mTableView.isHidden = false
//      self.mOutlineView.isHidden = false
//    }else{
//      let observer = EBOutletEvent ()
//      self.mSegmentedControlIndexObserver = observer
//      self.mSegmentedControlIndex.startsBeingObserved (by: observer)
//      observer.mEventCallBack = { [weak self] in
//        if let uwSelf = self {
//          uwSelf.mTableView.isHidden = uwSelf.mSegmentedControlIndex.propval == 1
//          uwSelf.mOutlineView.isHidden = uwSelf.mSegmentedControlIndex.propval == 0
//        }
//      }
//      self.mSegmentedControl.isHidden = false
//    }
  //--- Configure
    self.mDialog.title = inTitle
    self.configureWith (alreadyLoadedDocuments: [])
    self.mOpenButton.setClosureAction { [weak self] in self?.stopModalAndOpenDocumentAction () }
  //--- Dialog
    _ = NSApplication.shared.runModal (for: self.mDialog)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final func removeAllEntries () {
    self.mTableViewDataSource = []
    self.mTableViewFilteredDataSource = []
    self.mTableView.sortAndReloadData ()
//    self.mOutlineView.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func stopModalAndOpenDocumentAction () {
    NSApplication.shared.stopModal ()
    self.mDialog.orderOut (nil)
    let selectedRow = self.mTableView.selectedRow
    if selectedRow >= 0 {
      let selectedItem = self.mTableViewFilteredDataSource [selectedRow]
      if selectedItem.mFullPath != "" {
        let dc = NSDocumentController.shared
        let url = URL (fileURLWithPath: selectedItem.mFullPath)
        dc.openDocument (withContentsOf: url, display: true) { (document : NSDocument?, alreadyOpen : Bool, error : Error?) in }
      }
    }
    self.removeAllEntries ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildDataSource (alreadyLoadedDocuments inNames : Set <String>) { // Abstract method
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func noPartMessage () -> String { // Abstract method
    return "?"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func partLibraryPathForPath (_ inPath : String) -> String {  // Abstract method
    return inPath
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func buildTableViewDataSource (extension inFileExtension : String,
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
            if f.pathExtension.lowercased() == inFileExtension {
              let baseName = f.lastPathComponent.deletingPathExtension
              partCountDictionary [baseName] = partCountDictionary [baseName, default: 0] + 1
            }
          }
        }
      }
    //--- Build data source arraies
      var tableViewDataSource = [OpenInLibraryDialogFlatItem] ()
      for path in existingLibraryPathArray () {
        let baseDirectory = self.partLibraryPathForPath (path)
        var isDirectory : ObjCBool = false
        if fm.fileExists (atPath: baseDirectory, isDirectory: &isDirectory), isDirectory.boolValue {
          let files = try fm.subpathsOfDirectory (atPath: baseDirectory)
          for f in files {
            if f.pathExtension.lowercased () == inFileExtension {
              let fullpath = baseDirectory + "/" + f
              let baseName = f.lastPathComponent.deletingPathExtension
              let isDuplicated : Bool = partCountDictionary [baseName, default: 0] > 1
              let pathAsArray = f.deletingPathExtension.components (separatedBy: "/")
              tableViewDataSource.enterPart (pathAsArray, fullpath, isDuplicated, inNames.contains (baseName), inBuildPreviewShapeFunction)
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   AutoLayoutOutlineViewDelegate protocol methods
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func outlineViewDelegate_selectionDidChange (selectedRows inSelectedRows : IndexSet) {
//    let selectedRow = self.mOutlineView.selectedRow
//    if selectedRow >= 0 {
//      let selectedPart = self.mTableViewFilteredDataSource [selectedRow]
//      self.mStatusTextField.stringValue = selectedPart.statusString ()
//      self.mFullPathTextField.stringValue = selectedPart.mFullPath
//      self.mOpenButton.isEnabled = true
//      self.mPartImage.image = selectedPart.image
//      self.mPartImage.isHidden = false
//      self.mNoSelectedPartView.isHidden = true
//    }else{
//      self.mStatusTextField.stringValue = "—"
//      self.mFullPathTextField.stringValue = "—"
//      self.mOpenButton.isEnabled = false
//      self.mPartImage.image = nil
//      self.mPartImage.isHidden = true
//      self.mNoSelectedPartView.isHidden = false
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func outlineViewDelegate_indexesOfSelectedObjects () -> IndexSet {
//    return .init ()
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func outlineViewDelegate_addEntry () {
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func outlineViewDelegate_removeSelectedEntries () {
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func outlineViewDelegate_beginSorting () {
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func outlineViewDelegate_endSorting () {
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   AutoLayoutTableViewDelegate protocol methods
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_selectionDidChange (selectedRows inSelectedRows : IndexSet) {
    let selectedRow = self.mTableView.selectedRow
    if selectedRow >= 0 {
      let selectedPart = self.mTableViewFilteredDataSource [selectedRow]
      self.mStatusTextField.stringValue = selectedPart.statusString ()
      self.mFullPathTextField.stringValue = selectedPart.mFullPath
      self.mOpenButton.isEnabled = true
      self.mPartImage.image = selectedPart.image
      self.mPartImage.isHidden = false
      self.mNoSelectedPartView.isHidden = true
    }else{
      self.mStatusTextField.stringValue = "—"
      self.mFullPathTextField.stringValue = "—"
      self.mOpenButton.isEnabled = false
      self.mPartImage.image = nil
      self.mPartImage.isHidden = true
      self.mNoSelectedPartView.isHidden = false
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_indexesOfSelectedObjects () -> IndexSet {
    return .init ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_addEntry () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_removeSelectedEntries () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_beginSorting () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_endSorting () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SEARCH FIELD ACTION
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func searchFieldAction (_ _ : Any?) {
    let filter = self.mSearchField.stringValue.uppercased ()
  //--- Table view
    if filter.isEmpty {
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
    self.mTableView.sortAndReloadData ()
//    self.mOutlineView.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate final class OpenInLibraryDialogFlatItem {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mPartName : String
  let mIsDuplicated : Bool
  let mIsAlreadyLoaded : Bool
  let mFullPath : String
  private var mPartStatus : MetadataStatus? = nil
  private var mObjectImage : NSImage? = nil
  private let mBuildPreviewShapeFunction : (_ inRootObject : EBManagedObject?) -> NSImage?

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inPartName : String,
        _ inFullPath : String,
        _ inIsDuplicated : Bool,
        _ inIsAlreadyLoaded : Bool,
        _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    self.mPartName = inPartName
    self.mFullPath = inFullPath
    self.mIsDuplicated = inIsDuplicated
    self.mIsAlreadyLoaded = inIsAlreadyLoaded
    self.mBuildPreviewShapeFunction = inBuildPreviewShapeFunction
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func statusString () -> String {
    if self.mFullPath.isEmpty {
      return ""
    }else if self.mIsAlreadyLoaded {
      return "Already loaded"
    }else if self.mIsDuplicated {
      return "Duplicated"
    }else{
      do{
        switch try self.partStatus () {
        case .unknown :
          return "Unknown"
        case .ok :
          return "Ok"
        case .error :
          return "This part has error(s)"
        case .warning :
          return "This part has warning(s)"
        }
      }catch _ {
        return "This part cannot be read"
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func statusImage () -> NSImage? {
    if self.mFullPath.isEmpty {
      return nil
    }else if self.mIsDuplicated || self.mIsAlreadyLoaded {
      return NSImage.statusError
    }else{
      do{
      switch try self.partStatus () {
        case .unknown :
          return NSImage.statusNone
        case .ok :
          return NSImage.statusSuccess
        case .error :
          return NSImage.statusError
        case .warning :
          return NSImage.statusWarning
        }
      }catch _ {
        return NSImage (named: NSImage.Name ("exclamation"))
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func partStatus () throws -> MetadataStatus {
    if let s = self.mPartStatus {
      return s
    }else if self.mFullPath != "" {
      self.mPartStatus = .error
      let metadata = try getFileMetadata (atPath: self.mFullPath)
      self.mPartStatus = metadata.metadataStatus
      return metadata.metadataStatus
    }else{
      return .error
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func partStatusOk () -> Bool {
//    if let s = try? self.partStatus () {
//      return s == .ok
//    }else{
//      return false
//    }
//  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  var image : NSImage {
    if let image = self.mObjectImage {
      return image
    }else{
      let image = self.buildImage ()
      self.mObjectImage = image
      return image
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildImage () -> NSImage {
    var image : NSImage? = nil
    let fm = FileManager ()
    if let data = fm.contents (atPath: self.mFullPath) {
      let documentReadData = loadEasyBindingFile (fromData: data, documentName: self.mFullPath.lastPathComponent, undoManager: nil)
      switch documentReadData {
      case .ok (let documentData) :
        image = self.mBuildPreviewShapeFunction (documentData.documentRootObject)
      case .readError (let error) :
        let alert = NSAlert (error: error)
        _ = alert.runModal ()
      }
    }
    return image ?? NSImage ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension Array where Element == OpenInLibraryDialogFlatItem {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor fileprivate mutating func enterPart (
         _ inPathAsArray : [String],
         _ inFullpath : String,
         _ inIsDuplicated : Bool,
         _ inIsAlreadyLoaded : Bool,
         _ inBuildPreviewShapeFunction : @escaping (_ inRootObject : EBManagedObject?) -> NSImage?) {
    if inPathAsArray.count == 1 {
      self.append (OpenInLibraryDialogFlatItem (inPathAsArray [0], inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction))
    }else{
      var pathAsArray = inPathAsArray
      pathAsArray.remove (at: 0)
      self.enterPart (pathAsArray, inFullpath, inIsDuplicated, inIsAlreadyLoaded, inBuildPreviewShapeFunction)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
