//
//  CanariQuadrantSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/07/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariQuadrantSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (String (describing: type(of: self)))
  }

  //····················································································································

  override func sendAction (_ inAction : Selector?, to target : Any?) -> Bool {
    self.mController?.updateModel (self)
    return super.sendAction (inAction, to:target)
  }

  //····················································································································
  //    binding
  //····················································································································

  private var mController : Controller_CanariQuadrantSegmentedControl_quadrant?

  //····················································································································

  func bind_quadrant (_ object : EBReadWriteProperty_QuadrantRotation, file : String, line : Int) {
    self.mController = Controller_CanariQuadrantSegmentedControl_quadrant (object:object, outlet:self)
  }

  //····················································································································

  func unbind_quadrant () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariQuadrantSegmentedControl_quadrant
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariQuadrantSegmentedControl_quadrant : EBSimpleController {

  private let mObject : EBReadWriteProperty_QuadrantRotation
  private let mOutlet : CanariQuadrantSegmentedControl

  //····················································································································

  init (object : EBReadWriteProperty_QuadrantRotation, outlet : CanariQuadrantSegmentedControl) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object])
    self.mEventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch self.mObject.prop {
    case .empty :
      self.mOutlet.enableFromValueBinding (false)
      self.mOutlet.selectedSegment = -1
    case .single (let v) :
      self.mOutlet.enableFromValueBinding (true)
      self.mOutlet.selectedSegment = v.rawValue
    case .multiple :
      self.mOutlet.enableFromValueBinding (false)
      self.mOutlet.selectedSegment = -1
    }
  }

  //····················································································································

  func updateModel (_ sender : CanariQuadrantSegmentedControl) {
    if let v = QuadrantRotation (rawValue: self.mOutlet.selectedSegment) {
      _ = self.mObject.validateAndSetProp (v, windowForSheet:sender.window)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
