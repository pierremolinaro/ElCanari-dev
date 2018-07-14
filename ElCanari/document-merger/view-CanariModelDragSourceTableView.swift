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

let kDragAndDropModelType = "drag.and.drop.model.type"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariModelDragSourceTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariModelDragSourceTableView)
class CanariModelDragSourceTableView : NSTableView, EBUserClassNameProtocol, NSTableViewDataSource {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
    self.dataSource = self
    self.setDraggingSourceOperationMask (.move, forLocal:true)
    self.register (forDraggedTypes: [kDragAndDropModelType])
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
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

  private var mModelNameArray = [String] ()

  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return mModelNameArray.count
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    return mModelNameArray [row]
  }

  //····················································································································
  // Drag source
  //····················································································································

  func tableView (_ aTableView: NSTableView,
                  writeRowsWith rowIndexes: IndexSet,
                  to pboard : NSPasteboard) -> Bool {
    if rowIndexes.count == 1 {
      let idx = mModelNameArray [rowIndexes.first!]
      let data = "\(idx)".data (using: .ascii)
      pboard.declareTypes ([kDragAndDropModelType], owner:self)
      pboard.setData (data, forType:kDragAndDropModelType)
      return true
    }else{
      return false
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

  func updateModels (_ inNameArray : [String]) {
    self.mModelNameArray = inNameArray
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
      mOutlet.updateModels (v.modelNameArray)
    case .multiple :
      mOutlet.updateModels ([])
    }
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
