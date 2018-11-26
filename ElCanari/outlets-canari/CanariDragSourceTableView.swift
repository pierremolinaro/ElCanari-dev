//
//  CanariDragSourceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariDragSourceTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariDragSourceTableView)
class CanariDragSourceTableView : NSTableView, EBUserClassNameProtocol, NSTableViewDataSource {

  //····················································································································
  // INIT
  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    self.customInit ()
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    self.customInit ()
  }
  
  //····················································································································

  private final func customInit () {
    noteObjectAllocation (self)
    self.dataSource = self
  }
  
  //····················································································································
  // DEINIT
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    Register dragged type
  //····················································································································

  fileprivate var mDraggedType : NSPasteboard.PasteboardType? = nil
  fileprivate weak var mDocument : EBManagedDocument? = nil

  //····················································································································

  func register (document : EBManagedDocument, draggedType : NSPasteboard.PasteboardType) {
 //   self.setDraggingSourceOperationMask (.copy, forLocal: true)
 //   self.registerForDraggedTypes ([draggedType])
    self.mDraggedType = draggedType
    self.mDocument = document
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  private var mModelArray = [String] () {
    didSet {
      self.reloadData ()
    }
  }

  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return mModelArray.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    return mModelArray [row]
  }

  //····················································································································
  // Drag source
  //····················································································································

  func tableView (_ aTableView: NSTableView,
                  writeRowsWith rowIndexes: IndexSet,
                  to pboard : NSPasteboard) -> Bool {
    if let draggedType = self.mDraggedType, rowIndexes.count == 1 {
      let modelName : String = mModelArray [rowIndexes.first!]
      let data = modelName.data (using: .ascii)
      pboard.declareTypes ([draggedType], owner:self)
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

  private var mModelsController : EBReadOnlyController_StringArray?

  func bind_models (_ model:EBReadOnlyProperty_StringArray, file:String, line:Int) {
    mModelsController = EBReadOnlyController_StringArray (
      models:model,
      callBack: { [weak self] in self?.updateModels (model) }
    )
  }

  //····················································································································

  func unbind_models () {
    mModelsController?.unregister ()
    mModelsController = nil
  }

  //····················································································································

  func updateModels (_ models:EBReadOnlyProperty_StringArray) {
    switch models.prop {
    case .empty :
      self.mModelArray = []
    case .single (let v) :
      self.mModelArray = v
    case .multiple :
      self.mModelArray = []
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
