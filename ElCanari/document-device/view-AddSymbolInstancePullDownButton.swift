//
//  view-AddSymbolInstancePullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/03/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AddSymbolInstancePullDownButton : EBPopUpButton {

  //····················································································································

  fileprivate weak var mDocument : CustomizedDeviceDocument? = nil

  //····················································································································

  func register (document inDocument : CustomizedDeviceDocument) {
    self.mDocument = inDocument
  }

  //····················································································································

  @objc func addSymbolAction (_ inSender : NSMenuItem) {
    let symbolTypeName = inSender.title
    self.mDocument?.addSymbolInstance (named: symbolTypeName)
  }

  //····················································································································

  func updateItemList (from inModel : EBReadOnlyProperty_StringArray) {
    while self.numberOfItems > 1 {
      self.removeItem (at: self.numberOfItems - 1)
    }
    switch inModel.selection {
    case .empty, .multiple :
      ()
    case .single (let stringArray) :
      for s in stringArray {
        self.addItem (withTitle: s)
        self.itemArray.last?.action = #selector (AddSymbolInstancePullDownButton.addSymbolAction (_:))
        self.itemArray.last?.target = self
      }
    }
  }

  //····················································································································
  //  $symbolTypeNames binding
  //····················································································································

  private var mSymbolTypeNamesController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_symbolTypeNames (_ model : EBReadOnlyProperty_StringArray) {
    self.mSymbolTypeNamesController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateItemList (from: model) }
    )
  }

  //····················································································································

  final func unbind_symbolTypeNames () {
    self.mSymbolTypeNamesController?.unregister ()
    self.mSymbolTypeNamesController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
