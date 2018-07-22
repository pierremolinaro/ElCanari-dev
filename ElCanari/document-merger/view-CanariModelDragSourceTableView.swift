//
//  CanariModelDragSourceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let kDragAndDropModelType = "drag.and.drop.board.model"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariModelDragSourceTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariModelDragSourceTableView)
class CanariModelDragSourceTableView : NSTableView, EBUserClassNameProtocol, NSTableViewDataSource {

  //····················································································································

  @IBOutlet weak var mBoardView : CanariViewWithZoomAndFlip? = nil

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
    self.setDraggingSourceOperationMask (.copy, forLocal:true)
    self.register (forDraggedTypes: [kDragAndDropModelType])
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  private var mModelArray = [MergerBoardModelNameAndSize] ()

  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return mModelArray.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    return mModelArray [row].name
  }

  //····················································································································
  // Drag source
  //····················································································································

  func tableView (_ aTableView: NSTableView,
                  writeRowsWith rowIndexes: IndexSet,
                  to pboard : NSPasteboard) -> Bool {
    if rowIndexes.count == 1 {
      let modelName : String = mModelArray [rowIndexes.first!].name
      let data = modelName.data (using: .ascii)
      pboard.declareTypes ([kDragAndDropModelType], owner:self)
      pboard.setData (data, forType:kDragAndDropModelType)
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
    if let boardView = mBoardView, dragRows.count == 1 {
    //--- Get board view scale and flip
      let scale = boardView.actualScale ()
      let horizontalFlip : CGFloat = boardView.horizontalFlip () ? -1.0 : 1.0
      let verticalFlip   : CGFloat = boardView.verticalFlip ()   ? -1.0 : 1.0
    //--- Image size
      let width = scale * canariUnitToCocoa (self.mModelArray [dragRows.first!].width)
      let height = scale * canariUnitToCocoa (self.mModelArray [dragRows.first!].height)
    //--- By default, image is centered;
      dragImageOffset.pointee = NSPoint (x: horizontalFlip * width / 2.0, y: verticalFlip * height / 2.0)
    //--- Build image
      let r = CGRect (x:0.0, y:0.0, width : width, height:height)
      let bp = NSBezierPath (rect: r.insetBy (dx: 0.5, dy: 0.5))
      bp.lineWidth = 1.0
      let shape = EBShapes ([bp], NSColor.gray, .stroke)
      let pdfData = buildPDFimage (frame:r, shapes: shape, backgroundColor:NSColor.gray.withAlphaComponent (0.25))
      return NSImage (data: pdfData)!
    }else{
      return NSImage (named: "exclamation")!
    }
  }

  //····················································································································
  //    $models binding
  //····················································································································

  private var mModelsController : Controller_CanariModelDragSourceTableView_models?

  func bind_models (_ models:EBReadOnlyProperty_MergerBoardModelArray, file:String, line:Int) {
    mModelsController = Controller_CanariModelDragSourceTableView_models (models:models, outlet:self)
  }

  //····················································································································

  func unbind_models () {
    mModelsController?.unregister ()
    mModelsController = nil
  }

  //····················································································································

  func updateModels (_ inArray : [MergerBoardModelNameAndSize]) {
    self.mModelArray = inArray
    self.reloadData ()
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_objectLayer
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class Controller_CanariModelDragSourceTableView_models : EBSimpleController {

  private let mModels : EBReadOnlyProperty_MergerBoardModelArray
  private let mOutlet : CanariModelDragSourceTableView

  //····················································································································

  init (models : EBReadOnlyProperty_MergerBoardModelArray, outlet : CanariModelDragSourceTableView) {
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
      mOutlet.updateModels (v.modelArray)
    case .multiple :
      mOutlet.updateModels ([])
    }
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
