//
//  AutoLayoutEnumSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 22/01/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutEnumSegmentedControl : ALB_NSSegmentedControl {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (titles inTitles : [String], equalWidth inEqualWidth : Bool, size inSize : EBControlSize) {
    super.init (equalWidth: inEqualWidth, size: inSize.cocoaControlSize)
    self.segmentCount = inTitles.count
    var idx = 0
    for title in inTitles {
      self.setLabel (title, forSegment: idx)
      idx += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateIndex (fromEnumeration inObject : any EBEnumReadWriteObservableProtocol) {
    switch inObject.rawSelection {
    case .single (let rawValue) :
      self.enable (fromValueBinding: true, self.enabledBindingController ())
      self.setSelectedSegment (atIndex: rawValue)
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    }

//    if let v = inObject.rawValue () {
//      self.enable (fromValueBinding: true, self.enabledBindingController ())
//      self.setSelectedSegment (atIndex: v)
//    }else{
//      self.enable (fromValueBinding: false, self.enabledBindingController ())
//    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // SELECTED TAB DID CHANGE
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func selectedSegmentDidChange (_ _ : Any?) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedSegmentController?.updateModel (self.indexOfSelectedItem)
    return super.sendAction (action, to: to)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $selectedSegment binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSelectedSegmentController : Controller_AutoLayoutEnumSegmentedControl_Index? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_selectedSegment (_ inObject : any EBEnumReadWriteObservableProtocol) -> Self {
    self.mSelectedSegmentController = Controller_AutoLayoutEnumSegmentedControl_Index (
      object: inObject,
      outlet: self
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   Controller_AutoLayoutEnumSegmentedControl_Index
//--------------------------------------------------------------------------------------------------

fileprivate final class Controller_AutoLayoutEnumSegmentedControl_Index : EBObservablePropertyController {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mObject : any EBEnumReadWriteObservableProtocol

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (object inObject : any EBEnumReadWriteObservableProtocol,
        outlet inOutlet : AutoLayoutEnumSegmentedControl) {
    self.mObject = inObject
    super.init (
      observedObjects: [inObject],
      callBack: { [weak inOutlet] in inOutlet?.updateIndex (fromEnumeration: inObject) }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateModel (_ inValue : Int) {
    self.mObject.setFrom (rawValue: inValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   Controller_AutoLayoutSegmentedControl_Index
//--------------------------------------------------------------------------------------------------

//fileprivate final class Controller_AutoLayoutSegmentedControl_Index : EBObservablePropertyController {
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  private let mObject : EBObservableMutableProperty <Int>
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  init (object inObject : EBObservableMutableProperty <Int>, outlet inOutlet : AutoLayoutEnumSegmentedControl) {
//    self.mObject = inObject
//    super.init (observedObjects: [inObject], callBack: { [weak inOutlet] in inOutlet?.updateIndex (fromInteger: inObject) } )
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  func updateModel (_ inValue : Int) {
//    self.mObject.setProp (inValue)
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//}

//--------------------------------------------------------------------------------------------------
