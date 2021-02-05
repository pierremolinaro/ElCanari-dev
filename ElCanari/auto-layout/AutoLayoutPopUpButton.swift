//
//  AutoLayoutPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutPopUpButton : NSPopUpButton {

  //····················································································································

  init () {
    super.init (frame: NSRect (), pullsDown: false)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  func add (title inTitle : String) -> Self {
    self.addItem (withTitle: "")
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    ]
    let attributedTitle = NSAttributedString (string: inTitle, attributes: textAttributes)
    self.lastItem?.attributedTitle = attributedTitle
    return self
  }

  //····················································································································

  func updateIndex (_ object : EBReadWriteObservableEnumProtocol) {
    if let v = object.rawValue () {
      self.enableFromValueBinding (true)
      self.selectItem (at: v)
    }else{
      self.enableFromValueBinding (false)
    }
  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedIndexController?.updateModel ()
    return super.sendAction (action, to:to)
  }

  //····················································································································
  //  $selectedIndex binding
  //····················································································································

  private var mSelectedIndexController : Controller_AutoLayoutPopUpButton_Index? = nil

  //····················································································································

  func bind_selectedIndex (_ inObject : EBReadWriteObservableEnumProtocol) -> Self {
    self.mSelectedIndexController = Controller_AutoLayoutPopUpButton_Index (
      object: inObject,
      outlet: self
//      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
//   Controller_EBPopUpButton_Index
//----------------------------------------------------------------------------------------------------------------------

final class Controller_AutoLayoutPopUpButton_Index : EBReadOnlyPropertyController {

  //····················································································································

  private let mObject : EBReadWriteObservableEnumProtocol
  private let mOutlet : AutoLayoutPopUpButton

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet : AutoLayoutPopUpButton) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], callBack: { outlet.updateIndex (object) } )
  }

  //····················································································································

  func updateModel () {
    self.mObject.setFrom (rawValue: self.mOutlet.indexOfSelectedItem)
  }

  //····················································································································
}

//----------------------------------------------------------------------------------------------------------------------
