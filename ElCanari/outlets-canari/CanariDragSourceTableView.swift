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

class CanariDragSourceTableView : NSTableView, EBUserClassNameProtocol, NSTableViewDataSource {

  //····················································································································
  // INIT
  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
    self.dataSource = self  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
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
    self.mDraggedType = draggedType
    self.mDocument = document
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  private var mModelArray = [StringTag] () {
    didSet {
      self.reloadData ()
    }
  }

  //····················································································································

  func title (atIndex inIndex : Int) -> String {
    return self.mModelArray [inIndex].mString
  }

  //····················································································································

  func tag (atIndex inIndex : Int) -> Int {
    return self.mModelArray [inIndex].mTag
  }

  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mModelArray.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    return self.mModelArray [row].mString
  }

  //····················································································································
  // Drag source
  //····················································································································

  func tableView (_ aTableView: NSTableView,
                  writeRowsWith rowIndexes: IndexSet,
                  to pboard : NSPasteboard) -> Bool {
    if let draggedType = self.mDraggedType, rowIndexes.count == 1 {
      let cellName : String = self.mModelArray [rowIndexes.first!].mString
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

  private var mModelsController : EBSimpleController? = nil

  func bind_models (_ model : EBReadOnlyProperty_StringTagArray, file : String, line : Int) {
    self.mModelsController = EBSimpleController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
  }

  //····················································································································

  func unbind_models () {
    self.mModelsController?.unregister ()
    self.mModelsController = nil
  }

  //····················································································································

  func update (from model : EBReadOnlyProperty_StringTagArray) {
    switch model.prop {
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
//   StringTag
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct StringTag : Hashable {
  let mString : String
  let mTag : Int

  init (_ inString : String, _ inTag : Int) {
    mString = inString
    mTag = inTag
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   StringTagArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias StringTagArray = [StringTag]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
