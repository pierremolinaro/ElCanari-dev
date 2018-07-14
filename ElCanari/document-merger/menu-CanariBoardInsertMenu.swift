//
//  CanariBoardInsertMenu.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariBoardInsertMenu
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariBoardInsertMenu : NSMenu, EBUserClassNameProtocol {

  //····················································································································
  //   OUTLET
  //····················································································································

  @IBOutlet weak var mDocument : MergerDocument?  = nil // Reference to document SHOULD BE weak
  
  //····················································································································
  //   INIT
  //····················································································································

  required init (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
    self.autoenablesItems = true
  }

  //····················································································································

  override init (title: String) {
    super.init (title:title)
    noteObjectAllocation (self)
    self.autoenablesItems = true
  }
  
  //····················································································································
  //   DEINIT
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    BINDING names
  //····················································································································

  private var mNamesController : Controller_CanariBoardInsertMenu_names?

  //····················································································································

  func bind_names (_ names:EBReadOnlyProperty_MergerBoardModelArray, file:String, line:Int) {
    mNamesController = Controller_CanariBoardInsertMenu_names (names:names, outlet:self)
  }

  //····················································································································

  func unbind_names () {
    mNamesController?.unregister ()
    mNamesController = nil
  }

  //····················································································································

  func setNames (_ inArray : [MergerBoardModelNameAndSize]) {
    // NSLog ("\(inArray)")
    self.removeAllItems ()
    if inArray.count == 0 {
      self.addItem (withTitle: "No Board Model to Insert", action: nil, keyEquivalent: "")
    }else{
      for model in inArray {
        self.addItem (withTitle: "Insert \"\(model.name)\"", action: #selector (MergerDocument.insertBoardAction (_:)), keyEquivalent: "")
        self.items.last?.representedObject = InsertBoardMenuRepresentedObject (boardModelName:model.name)
        self.items.last?.target = mDocument
        self.items.last?.isEnabled = true
      }
    //--- Add "Insert an array of boards…" item, with no represented object
      self.addItem (withTitle: "Insert an array of boards…", action: #selector (MergerDocument.insertBoardAction (_:)), keyEquivalent: "")
      self.items.last?.target = mDocument
      self.items.last?.isEnabled = true
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardInsertMenu_names
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardInsertMenu_names : EBSimpleController {

  private let mNames : EBReadOnlyProperty_MergerBoardModelArray
  private let mOutlet : CanariBoardInsertMenu

  //····················································································································

  init (names : EBReadOnlyProperty_MergerBoardModelArray, outlet : CanariBoardInsertMenu) {
    mNames = names
    mOutlet = outlet
    super.init (observedObjects:[names], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mNames.prop {
    case .empty :
      mOutlet.setNames ([])
    case .single (let v) :
      mOutlet.setNames (v.modelArray)
    case .multiple :
      mOutlet.setNames ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class InsertBoardMenuRepresentedObject : EBSimpleClass {
  let boardModelName : String

  init (boardModelName inName : String) {
    boardModelName = inName
    super.init ()
  }
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
