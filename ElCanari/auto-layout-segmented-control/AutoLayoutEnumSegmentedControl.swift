//
//  AutoLayoutEnumSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 22/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutEnumSegmentedControl : AutoLayoutBase_NSSegmentedControl {

  //····················································································································

  init (titles inTitles : [String], equalWidth inEqualWidth : Bool, size inSize : EBControlSize) {
    super.init (equalWidth: inEqualWidth, size: inSize)
    self.segmentCount = inTitles.count
    var idx = 0
    for title in inTitles {
      self.setLabel (title, forSegment: idx)
      idx += 1
    }
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  func updateIndex (_ object : EBReadWriteObservableEnumProtocol) {
    if let v = object.rawValue () {
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.setSelectedSegment (atIndex: v)
    }else{
      self.enable (fromValueBinding: false, self.enabledBindingController)
    }
  }

  //····················································································································

  func setSelectedSegment (atIndex inIndex : Int) {
    if self.segmentCount > 0 {
      if inIndex < 0 {
        self.selectedSegment = 0
      }else if inIndex >= self.segmentCount {
        self.selectedSegment = self.segmentCount - 1
      }else{
        self.selectedSegment = inIndex
      }
      self.selectedSegmentDidChange (nil)
    }
  }

  //····················································································································
  // SELECTED TAB DID CHANGE
  //····················································································································

  @objc private func selectedSegmentDidChange (_ inSender : Any?) {
  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedIndexController?.updateModel (self.indexOfSelectedItem)
    return super.sendAction (action, to:to)
  }

  //····················································································································
  //  $selectedSegment binding
  //····················································································································

  private var mSelectedIndexController : Controller_AutoLayoutEnumSegmentedControl_Index? = nil

  //····················································································································

  final func bind_selectedSegment (_ inObject : EBReadWriteObservableEnumProtocol) -> Self {
    self.mSelectedIndexController = Controller_AutoLayoutEnumSegmentedControl_Index (
      object: inObject,
      outlet: self
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_EBPopUpButton_Index
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class Controller_AutoLayoutEnumSegmentedControl_Index : EBObservablePropertyController {

  //····················································································································

  private let mObject : EBReadWriteObservableEnumProtocol

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet inOutlet : AutoLayoutEnumSegmentedControl) {
    self.mObject = object
    super.init (observedObjects: [object], callBack: { [weak inOutlet] in inOutlet?.updateIndex (object) } )
  }

  //····················································································································

  func updateModel (_ inValue : Int) {
    self.mObject.setFrom (rawValue: inValue)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————