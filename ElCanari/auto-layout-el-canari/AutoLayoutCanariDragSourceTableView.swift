//
//  AutoLayoutCanariDragSourceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   AutoLayoutCanariDragSourceTableView
//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariDragSourceTableView : NSScrollView, NSTableViewDataSource, NSTableViewDelegate {

  private let mTableView = InternalDragSourceTableView ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    let leftColumn = NSTableColumn ()
    leftColumn.minWidth = 20.0
    leftColumn.maxWidth = 400.0
    leftColumn.isEditable = false
    leftColumn.resizingMask = .autoresizingMask
    self.mTableView.addTableColumn (leftColumn)

  //--- Set sort descriptor
    let tableColumns = self.mTableView.tableColumns
    if tableColumns.count == 1 {
      let column = tableColumns [0]
      let sortDescriptor = NSSortDescriptor (key: column.identifier.rawValue, ascending: true)
      column.sortDescriptorPrototype = sortDescriptor
      self.mTableView.sortDescriptors = [sortDescriptor] // This shows the sort indicator
    }
    self.mTableView.dataSource = self
    self.mTableView.delegate = self
    self.mTableView.headerView = nil
    self.mTableView.cornerView = nil
    self.mTableView.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
    self.mTableView.usesAutomaticRowHeights = true

    self.drawsBackground = false
    self.documentView = self.mTableView
    self.hasHorizontalScroller = false
    self.hasVerticalScroller = true
//    Swift.print ("self.automaticallyAdjustsContentInsets \(self.automaticallyAdjustsContentInsets)")
    self.automaticallyAdjustsContentInsets = true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Register dragged type
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate var mDraggedType : NSPasteboard.PasteboardType? = nil
  fileprivate weak var mDocument : EBAutoLayoutManagedDocument? = nil // SHOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func register (document inDocument : EBAutoLayoutManagedDocument,
                 draggedType inDraggedType : NSPasteboard.PasteboardType) {
    self.mDraggedType = inDraggedType
    self.mDocument = inDocument
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    T A B L E V I E W    D A T A S O U R C E : numberOfRows (in:)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func numberOfRows (in inTableView : NSTableView) -> Int {
    // Swift.print ("numberOfRows \(self.mModelArray.count)")
    return self.mModelArray.count
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    T A B L E V I E W    D E L E G A T E : tableView:viewForTableColumn:row:
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableView (_ inTableView : NSTableView,
                  viewFor inTableColumn : NSTableColumn?,
                  row inRowIndex : Int) -> NSView? {
    let text = NSTextField ()
    text.alignment = .left
    text.drawsBackground = false
    text.isBordered = false
    text.isSelectable = true
    text.isEditable = false
    text.stringValue = self.mModelArray [inRowIndex].string
    text.toolTip = self.mModelArray [inRowIndex].string
    return text
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Table view data source protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mModelArray = [StringTag] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func setModel (_ inModel : [StringTag]) {
  //--- Note selected rows
    var selectedRowContents = Set <String> ()
    let currentSelectedRowIndexes = self.mTableView.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mModelArray.count {
        selectedRowContents.insert (self.mModelArray [idx].string)
      }
    }
  //--- Assignment
    self.mModelArray = inModel
  //-- Sort
    if self.mTableView.sortDescriptors.count == 1 {
      let sortDescriptor = self.mTableView.sortDescriptors [0]
      if sortDescriptor.ascending {
        self.mModelArray.sort { $0.string.localizedStandardCompare ($1.string) == .orderedAscending }
      }else{
        self.mModelArray.sort { $0.string.localizedStandardCompare ($1.string) == .orderedDescending }
      }
    }
  //--- Tell Table view to reload
    self.mTableView.reloadData ()
  //--- Restore selection
    var newSelectedRowIndexes = IndexSet ()
    var idx = 0
    while idx < self.mModelArray.count {
      if selectedRowContents.contains (self.mModelArray [idx].string) {
        newSelectedRowIndexes.insert (idx)
      }
      idx += 1
    }
    if (newSelectedRowIndexes.count == 0) && (self.mModelArray.count > 0) {
      if let firstIndex : Int = currentSelectedRowIndexes.first {
        if firstIndex < self.mModelArray.count {
          newSelectedRowIndexes.insert (firstIndex)
        }else{
          newSelectedRowIndexes.insert (self.mModelArray.count - 1)
        }
      }else{
        newSelectedRowIndexes.insert (0)
      }
    }
    self.mTableView.selectRowIndexes (newSelectedRowIndexes, byExtendingSelection: false)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    TABLEVIEW DELEGATE : tableView:viewForTableColumn:mouseDownInHeaderOfTableColumn:
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableView (_ inTableView : NSTableView, mouseDownInHeaderOf inTableColumn : NSTableColumn) {
    self.setModel (self.mModelArray)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   GETTERS
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func title (atIndex inIndex : Int) -> String {
//    return self.mModelArray [inIndex].string
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tag (atIndex inIndex : Int) -> Int {
    return self.mModelArray [inIndex].tag
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Drag source
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // The following method is obsolete,
  // use tableView (_:pasteboardWriterForRow:) and tableView (_:draggingSession:willBeginAt:forRowIndexes:)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func tableView (_ inTableView : NSTableView, // NSTableViewDataSource
//                  writeRowsWith inRowIndexes : IndexSet,
//                  to inPasteboard : NSPasteboard) -> Bool {
//    if DEBUG_DRAG_AND_DROP {
//      Swift.print (self.className + "." + #function)
//    }
//    if let draggedType = self.mDraggedType, inRowIndexes.count == 1 {
//      self.mTableView.selectRowIndexes (inRowIndexes, byExtendingSelection: false)
//      let cellName : String = self.mModelArray [inRowIndexes.first!].string
//      inPasteboard.declareTypes ([draggedType], owner: self)
//    //--- Associated data is cell name
//      let data = cellName.data (using: .ascii)
//      inPasteboard.setData (data, forType: draggedType)
//      return true
//    }else{
//      return false
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableView (_ inTableView : NSTableView,
                  pasteboardWriterForRow inRowIndex : Int) -> (any NSPasteboardWriting)? {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
    if let draggedType = self.mDraggedType {
      self.mTableView.selectRowIndexes (IndexSet (integer: inRowIndex), byExtendingSelection: false)
      let pasteboardItem = NSPasteboardItem ()
      let cellName : String = self.mModelArray [inRowIndex].string
      pasteboardItem.setString (cellName, forType: draggedType)
      return pasteboardItem
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // https://stackoverflow.com/questions/51360662/how-do-i-stop-nstableview-drag-images-shrinking-when-leaving-the-table
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableView (_ inTableView : NSTableView,
                  draggingSession inSession : NSDraggingSession,
                  willBeginAt _ : NSPoint,
                  forRowIndexes inRowIndexes : IndexSet) {
    if DEBUG_DRAG_AND_DROP {
      Swift.print (self.className + "." + #function)
    }
    if let document = self.mDocument, inRowIndexes.count == 1, let rowIndex = inRowIndexes.first {
      let (image, imageOffset) = document.image (forDragSource: self, forDragRowIndex: rowIndex)
      unsafe inSession.enumerateDraggingItems (
        options: .concurrent,
        for: nil,
        classes: [NSPasteboardItem.self],
        searchOptions: [:],
        using: { (draggingItem : NSDraggingItem, index, stop) in
          let r = NSRect (
            x: inSession.draggingLocation.x + imageOffset.x - image.size.width / 2.0,
            y: inSession.draggingLocation.y + imageOffset.y - image.size.height / 2.0,
            width: image.size.width,
            height: image.size.height
          )
          draggingItem.setDraggingFrame (r, contents: image)
        }
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    $models binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mModelsController : EBObservablePropertyController? = nil

  final func bind_models (_ inModel : EBObservableProperty <StringTagArray>) -> Self {
    self.mModelsController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.update (from: inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_models () {
//    self.mModelsController?.unregister ()
//    self.mModelsController = nil
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func update (from model : EBObservableProperty <StringTagArray>) {
    switch model.selection {
    case .empty, .multiple :
      self.setModel ([])
    case .single (let v) :
      self.setModel (v)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   InternalDragSourceTableView
//--------------------------------------------------------------------------------------------------

fileprivate final class InternalDragSourceTableView : NSTableView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
