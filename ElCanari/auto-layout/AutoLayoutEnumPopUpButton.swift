//
//  AutoLayoutEnumPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutEnumPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init (titles inTitles : [String]) {
    super.init (frame: NSRect (), pullsDown: false)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.bezelStyle = .roundRect
    self.controlSize = .small
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    ]
    for title in inTitles {
      self.addItem (withTitle: "")
      let attributedTitle = NSAttributedString (string: title, attributes: textAttributes)
      self.lastItem?.attributedTitle = attributedTitle
    }
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }
  
  //····················································································································

  override func ebCleanUp () {
    self.mSelectedIndexController?.unregister ()
    self.mSelectedIndexController = nil
    super.ebCleanUp ()
  }


  //····················································································································

  func updateIndex (_ object : EBReadWriteObservableEnumProtocol) {
    if let v = object.rawValue () {
      self.enable (fromValueBinding: true)
      self.selectItem (at: v)
    }else{
      self.enable (fromValueBinding: false)
    }
  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedIndexController?.updateModel (self.indexOfSelectedItem)
    return super.sendAction (action, to:to)
  }

  //····················································································································
  //  $selectedIndex binding
  //····················································································································

  private var mSelectedIndexController : Controller_AutoLayoutEnumPopUpButton_Index? = nil

  //····················································································································

  func bind_selectedIndex (_ inObject : EBReadWriteObservableEnumProtocol) -> Self {
    self.mSelectedIndexController = Controller_AutoLayoutEnumPopUpButton_Index (
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

fileprivate final class Controller_AutoLayoutEnumPopUpButton_Index : EBReadOnlyPropertyController {

  //····················································································································

  private let mObject : EBReadWriteObservableEnumProtocol

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet inOutlet : AutoLayoutEnumPopUpButton) {
    self.mObject = object
    super.init (observedObjects: [object], callBack: { [weak inOutlet] in inOutlet?.updateIndex (object) } )
  }

  //····················································································································

  func updateModel (_ inValue : Int) {
    self.mObject.setFrom (rawValue: inValue)
  }

  //····················································································································
}

//----------------------------------------------------------------------------------------------------------------------
