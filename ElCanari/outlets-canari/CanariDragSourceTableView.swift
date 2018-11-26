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

  private var mModelArray = [String] ()

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

  private var mModelsController : Controller_CanariModelDragSourceTableView_models?

  func bind_models (_ models:EBReadOnlyProperty_StringArray, file:String, line:Int) {
    mModelsController = Controller_CanariModelDragSourceTableView_models (models:models, outlet:self)
  }

  //····················································································································

  func unbind_models () {
    mModelsController?.unregister ()
    mModelsController = nil
  }

  //····················································································································

  func updateModels (_ inArray : [String]) {
    self.mModelArray = inArray
    self.reloadData ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_objectLayer
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class Controller_CanariModelDragSourceTableView_models : EBSimpleController {

  private let mModels : EBReadOnlyProperty_StringArray
  private let mOutlet : CanariDragSourceTableView

  //····················································································································

  init (models : EBReadOnlyProperty_StringArray, outlet : CanariDragSourceTableView) {
    mModels = models
    mOutlet = outlet
    super.init (observedObjects:[models], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mModels.prop {
    case .empty :
      mOutlet.updateModels ([])
    case .single (let v) :
      mOutlet.updateModels (v)
    case .multiple :
      mOutlet.updateModels ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
