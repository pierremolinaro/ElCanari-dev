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
  // MARK: -
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

  fileprivate func updateOutlet (_ names : EBReadOnlyProperty_StringArray) {
    switch names.prop {
    case .empty :
      self.setNames ([])
    case .single (let v) :
      self.setNames (v)
    case .multiple :
      self.setNames ([])
    }
  }

  //····················································································································

  private var mNamesController : EBSimpleController? = nil

  //····················································································································

  func bind_names (_ names:EBReadOnlyProperty_StringArray, file:String, line:Int) {
    self.mNamesController = EBSimpleController (
      observedObjects: [names],
      callBack: { [weak self] in self?.updateOutlet (names) }
    )
  }

  //····················································································································

  func unbind_names () {
    self.mNamesController?.unregister ()
    self.mNamesController = nil
  }

  //····················································································································

  func setNames (_ inArray : [String]) {
    // NSLog ("\(inArray)")
    self.removeAllItems ()
    if inArray.count == 0 {
      self.addItem (withTitle: "No Board Model to Insert", action: nil, keyEquivalent: "")
    }else{
      for modelName in inArray {
        self.addItem (withTitle: "Insert \"\(modelName)\"", action: #selector (MergerDocument.insertBoardAction (_:)), keyEquivalent: "")
        self.items.last?.representedObject = InsertBoardMenuRepresentedObject (boardModelName:modelName)
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

class InsertBoardMenuRepresentedObject : EBObject {
  let boardModelName : String

  init (boardModelName inName : String) {
    boardModelName = inName
    super.init ()
  }
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
