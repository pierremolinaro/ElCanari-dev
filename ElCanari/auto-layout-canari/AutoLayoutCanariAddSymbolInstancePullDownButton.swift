//
//  AutoLayoutCanariAddSymbolInstancePullDownButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 29/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariAddSymbolInstancePullDownButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  init () {
    super.init (pullsDown: true, size: .small)
    self.addItem (withTitle: "Embedded Library")
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  private weak var mDocument : AutoLayoutDeviceDocument? = nil

  //····················································································································

  func register (deviceDocument inDocument : AutoLayoutDeviceDocument) {
    self.mDocument = inDocument
  }
  
  //····················································································································

  @objc func addSymbolAction (_ inSender : NSMenuItem) {
    let symbolTypeName = inSender.title
    self.addSymbolInstance (named: symbolTypeName)
  }

  //····················································································································

  private func addSymbolInstance (named inSymbolTypeName : String ) {
    if let document = self.mDocument {
    //--- Find symbol type
      var possibleSymbolType : SymbolTypeInDevice? = nil
      for candidateSymbolType in document.rootObject.mSymbolTypes_property.propval.values {
        if candidateSymbolType.mTypeName == inSymbolTypeName {
          possibleSymbolType = candidateSymbolType
          break
        }
      }
    //--- Add instance
      if let symbolType = possibleSymbolType {
        let newSymbolInstance = SymbolInstanceInDevice (document.undoManager)
        newSymbolInstance.mType_property.setProp (symbolType)
        document.rootObject.mSymbolInstances_property.add (newSymbolInstance)
        for pinType in symbolType.mPinTypes_property.propval.values {
          let pinInstance = SymbolPinInstanceInDevice (document.undoManager)
          pinInstance.mType_property.setProp (pinType)
          newSymbolInstance.mPinInstances_property.add (pinInstance)
        }
        document.symbolDisplayController.select (object: newSymbolInstance)
      }
    }
  }

  //····················································································································

  func updateItemList (from inModel : EBObservableProperty <StringArray>) {
    while self.numberOfItems > 1 {
      self.removeItem (at: self.numberOfItems - 1)
    }
    switch inModel.selection {
    case .empty, .multiple :
      ()
    case .single (let stringArray) :
      for s in stringArray {
        self.addItem (withTitle: s)
        self.itemArray.last?.action = #selector (Self.addSymbolAction (_:))
        self.itemArray.last?.target = self
      }
    }
  }

  //····················································································································
  //  $symbolTypeNames binding
  //····················································································································

  private var mSymbolTypeNamesController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_symbolTypeNames (_ model : EBObservableProperty <StringArray>) -> Self {
    self.mSymbolTypeNamesController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateItemList (from: model) }
    )
    return self
  }

  //····················································································································

//  final func unbind_symbolTypeNames () {
//    self.mSymbolTypeNamesController?.unregister ()
//    self.mSymbolTypeNamesController = nil
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
