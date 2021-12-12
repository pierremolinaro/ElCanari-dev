//
//  AutoLayoutPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutPullDownButton : InternalAutoLayoutPopUpButton {

  //····················································································································

  init (title inTitle : String, size inSize : EBControlSize) {
    super.init (pullsDown: true, size: inSize)

    self.addItem (withTitle: inTitle)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  var mControlerArray = [EBReadOnlyPropertyController] ()

  //····················································································································

  override func ebCleanUp () {
    for controller in self.mControlerArray {
      controller.unregister ()
    }
    super.ebCleanUp ()
  }

  //····················································································································

  final func add (item inMenuItemDescriptor : AutoLayoutMenuItemDescriptor) -> Self {
    self.addItem (withTitle: inMenuItemDescriptor.title)
//    let textAttributes : [NSAttributedString.Key : Any] = [
//      NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
//    ]
//    let attributedTitle = NSAttributedString (string: inMenuItemDescriptor.title, attributes: textAttributes)
//    self.lastItem?.attributedTitle = attributedTitle
    self.lastItem?.target = inMenuItemDescriptor.target
    self.lastItem?.action = inMenuItemDescriptor.selector
  //--- Add Enabled binding ?
    switch inMenuItemDescriptor.expression {
    case .empty :
      ()
    default :
      let lastItem = self.lastItem
      var modelArray = [EBObservableObjectProtocol] ()
      inMenuItemDescriptor.expression.addModelsTo (&modelArray)
      let controller = EBReadOnlyPropertyController (
        observedObjects: modelArray,
        callBack: { [weak self] in self?.enable (item: lastItem, from: inMenuItemDescriptor.expression.compute ()) }
      )
      self.mControlerArray.append (controller)
    }
  //---
    return self
  }

  //····················································································································

  fileprivate func enable (item inMenuItem : NSMenuItem?, from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      inMenuItem?.isEnabled = false
    case .single (let v) :
      inMenuItem?.isEnabled = v
    }
  }

  //····················································································································
  //  $items binding
  //····················································································································

  private var mItemsController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_items (_ model : EBReadOnlyProperty_StringArray) -> Self {
    self.mItemsController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_StringArray) {
    switch model.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false)
    case .single (let titleArray) :
      self.enable (fromValueBinding: true)
      while self.numberOfItems > 1 {
        self.removeItem (at: self.numberOfItems - 1)
      }
      for itemTitle in titleArray {
        self.addItem (withTitle: itemTitle)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
