//
//  CanariDragSourceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   StringTag
//----------------------------------------------------------------------------------------------------------------------

struct StringTag : Hashable {
  let string : String
  let tag : Int
}

//----------------------------------------------------------------------------------------------------------------------
//   StringTagArray
//----------------------------------------------------------------------------------------------------------------------

typealias StringTagArray = [StringTag]

//----------------------------------------------------------------------------------------------------------------------
//   CanariDragSourceTableView
//----------------------------------------------------------------------------------------------------------------------

final class CanariDragSourceTableView : NSTableView, EBUserClassNameProtocol, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································
  // INIT
  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // AWAKE FROM NIB
  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
  //--- Set sort descriptor
    let tableColumns = self.tableColumns
    if tableColumns.count == 1 {
      let column = tableColumns [0]
      let sortDescriptor = NSSortDescriptor (key: column.identifier.rawValue, ascending: true)
      column.sortDescriptorPrototype = sortDescriptor
      self.sortDescriptors = [sortDescriptor] // This shows the sort indicator
    }
    self.dataSource = self
    self.delegate = self
  }

  //····················································································································
  //    Register dragged type
  //····················································································································

  fileprivate var mDraggedType : NSPasteboard.PasteboardType? = nil
  fileprivate weak var mDocument : EBManagedXibDocument? = nil

  //····················································································································

  func register (document : EBManagedXibDocument, draggedType : NSPasteboard.PasteboardType) {
    self.mDraggedType = draggedType
    self.mDocument = document
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
    if let tableColumnIdentifier = inTableColumn?.identifier,
       let result = tableView.makeView (withIdentifier: tableColumnIdentifier, owner: self) as? NSTableCellView {
      if !reuseTableViewCells () {
        result.identifier = nil // So result cannot be reused, will be freed
      }
      result.textField?.stringValue = self.mModelArray [inRowIndex].string
      return result
    }else{
      return nil
    }
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  private var mModelArray = [StringTag] ()

  //····················································································································

  private func setModel (_ inModel : [StringTag]) {
  //--- Note selected rows
    var selectedRowContents = Set <String> ()
    let currentSelectedRowIndexes = self.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mModelArray.count {
        selectedRowContents.insert (self.mModelArray [idx].string)
      }
    }
  //--- Assignment
    self.mModelArray = inModel
  //-- Sort
    if self.sortDescriptors.count == 1 {
      let sortDescriptor = self.sortDescriptors [0]
      if sortDescriptor.ascending {
        self.mModelArray.sort (by: { $0.string.localizedStandardCompare ($1.string) == .orderedAscending } )
      }else{
        self.mModelArray.sort (by: { $0.string.localizedStandardCompare ($1.string) == .orderedDescending } )
      }
    }
  //--- Tell Table view to reload
    self.reloadData ()
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
    self.selectRowIndexes (newSelectedRowIndexes, byExtendingSelection: false)
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
      let cellName : String = self.mModelArray [rowIndexes.first!].string
      pboard.declareTypes ([draggedType], owner:self)
    //--- Associated data is cell name
      let data = cellName.data (using: .ascii)
      pboard.setData (data, forType:draggedType)
      return true
    }else{
      return false
    }
  }

  //····················································································································
  // Providing the drag image
  //····················································································································

  override func dragImageForRows (with dragRows: IndexSet,
                                  tableColumns: [NSTableColumn],
                                  event dragEvent: NSEvent,
                                  offset dragImageOffset: NSPointPointer) -> NSImage {
    if let document = self.mDocument {
      return document.dragImageForRows (
        source: self,
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
  //    $models binding
  //····················································································································

  private var mModelsController : EBReadOnlyPropertyController? = nil

  final func bind_models (_ model : EBReadOnlyProperty_StringTagArray) {
    self.mModelsController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: {self.update (from: model) }
    )
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

//----------------------------------------------------------------------------------------------------------------------
