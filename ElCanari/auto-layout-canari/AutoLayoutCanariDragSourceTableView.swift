//
//  AutoLayoutCanariDragSourceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   StringTag
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct StringTag : Hashable {
  let string : String
  let tag : Int
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   StringTagArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias StringTagArray = [StringTag]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariDragSourceTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariDragSourceTableView : NSScrollView, EBUserClassNameProtocol, NSTableViewDataSource, NSTableViewDelegate {

  private let mTableView = InternalDragSourceTableView ()

  //····················································································································
  // INIT
  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
//    self.translatesAutoresizingMaskIntoConstraints = false // DO NOT UNCOMMENT

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

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    Register dragged type
  //····················································································································

  fileprivate var mDraggedType : NSPasteboard.PasteboardType? = nil

  //····················································································································

  func register (document : EBAutoLayoutManagedDocument, draggedType : NSPasteboard.PasteboardType) {
    self.mDraggedType = draggedType
    self.mTableView.mDocument = document
    self.mTableView.mSource = self
  }

  //····················································································································
  //    T A B L E V I E W    D A T A S O U R C E : numberOfRows (in:)
  //····················································································································

  func numberOfRows (in _ : NSTableView) -> Int {
    // Swift.print ("numberOfRows \(self.mModelArray.count)")
    return self.mModelArray.count
  }

  //····················································································································
  //    T A B L E V I E W    D E L E G A T E : tableView:viewForTableColumn:row:
  //····················································································································

  func tableView (_ tableView : NSTableView,
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

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  private var mModelArray = [StringTag] ()

  //····················································································································

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
        self.mModelArray.sort (by: { $0.string.localizedStandardCompare ($1.string) == .orderedAscending } )
      }else{
        self.mModelArray.sort (by: { $0.string.localizedStandardCompare ($1.string) == .orderedDescending } )
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

  //····················································································································
  //    T A B L E V I E W    D E L E G A T E : tableView:viewForTableColumn:mouseDownInHeaderOfTableColumn:
  //····················································································································

  func tableView (_ tableView : NSTableView, mouseDownInHeaderOf inTableColumn : NSTableColumn) {
    self.setModel (self.mModelArray)
  }

  //····················································································································
  //   GETTERS
  //····················································································································

  func title (atIndex inIndex : Int) -> String {
    return self.mModelArray [inIndex].string
  }

  //····················································································································

  func tag (atIndex inIndex : Int) -> Int {
    return self.mModelArray [inIndex].tag
  }

  //····················································································································
  // Drag source
  //····················································································································

  func tableView (_ aTableView: NSTableView,
                  writeRowsWith rowIndexes: IndexSet,
                  to pboard : NSPasteboard) -> Bool {
    if let draggedType = self.mDraggedType, rowIndexes.count == 1 {
      self.mTableView.selectRowIndexes (rowIndexes, byExtendingSelection: false)
      let cellName : String = self.mModelArray [rowIndexes.first!].string
      pboard.declareTypes ([draggedType], owner:self)
    //--- Associated data is cell name
      let data = cellName.data (using: .ascii)
      pboard.setData (data, forType: draggedType)
      return true
    }else{
      return false
    }
  }

  //····················································································································
  //    $models binding
  //····················································································································

  private var mModelsController : EBObservablePropertyController? = nil

  final func bind_models (_ model : EBReadOnlyProperty_StringTagArray) -> Self {
    self.mModelsController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  //····················································································································

  final func unbind_models () {
    self.mModelsController?.unregister ()
    self.mModelsController = nil
  }

  //····················································································································

  func update (from model : EBReadOnlyProperty_StringTagArray) {
    switch model.selection {
    case .empty, .multiple :
      self.setModel ([])
    case .single (let v) :
      self.setModel (v)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   InternalDragSourceTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class InternalDragSourceTableView : NSTableView, EBUserClassNameProtocol {

  weak var mDocument : EBAutoLayoutManagedDocument? = nil
  weak var mSource : AutoLayoutCanariDragSourceTableView? = nil

  //····················································································································
  // INIT
  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // Providing the drag image
  //····················································································································

  override func dragImageForRows (with dragRows: IndexSet,
                                  tableColumns: [NSTableColumn],
                                  event dragEvent: NSEvent,
                                  offset dragImageOffset: NSPointPointer) -> NSImage {
    if let document = self.mDocument, let source = self.mSource {
      return document.dragImageForRows (
        source: source,
        with: dragRows,
        tableColumns: tableColumns,
        event: dragEvent,
        offset: dragImageOffset
      )
    }else{
      return NSImage (named: NSImage.Name ("exclamation"))!
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
