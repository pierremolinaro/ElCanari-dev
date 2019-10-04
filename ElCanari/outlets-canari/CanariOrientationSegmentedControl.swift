//
//  CanariOrientationSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/10/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariOrientationSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func sendAction (_ inAction : Selector?, to target : Any?) -> Bool {
    let angle = self.selectedSegment * 90_000
    self.mController?.updateModel (self, angle)
    return super.sendAction (inAction, to:target)
  }

  //····················································································································
  //    binding
  //····················································································································

  fileprivate func updateSelectedSegment (_ object : EBReadWriteProperty_Int) {
    switch object.prop {
    case .empty :
      self.enableFromValueBinding (false)
      self.selectedSegment = -1
    case .single (let v) :
      self.enableFromValueBinding (true)
      self.setSelected (v ==       0, forSegment: 0)
      self.setSelected (v ==  90_000, forSegment: 1)
      self.setSelected (v == 180_000, forSegment: 2)
      self.setSelected (v == 270_000, forSegment: 3)
    case .multiple :
      self.enableFromValueBinding (false)
      self.selectedSegment = -1
    }
  }

  //····················································································································

  private var mController : Controller_CanariOrientationSegmentedControl_angle? = nil

  //····················································································································

  func bind_angle (_ object : EBReadWriteProperty_Int, file : String, line : Int) {
    self.mController = Controller_CanariOrientationSegmentedControl_angle (object: object, outlet: self)
  }

  //····················································································································

  func unbind_angle () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariOrientationSegmentedControl_angle
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariOrientationSegmentedControl_angle : EBSimpleController {

  private let mObject : EBReadWriteProperty_Int
  private let mOutlet : CanariOrientationSegmentedControl

  //····················································································································

  init (object : EBReadWriteProperty_Int, outlet : CanariOrientationSegmentedControl) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects: [object], callBack: { outlet.updateSelectedSegment (object) })
  }

  //····················································································································

  func updateModel (_ inSender : CanariOrientationSegmentedControl, _ inAngle : Int) {
    _ = self.mObject.validateAndSetProp (inAngle, windowForSheet: inSender.window)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
