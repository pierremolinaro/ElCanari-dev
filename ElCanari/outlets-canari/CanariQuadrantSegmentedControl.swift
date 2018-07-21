//
//  CanariQuadrantSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariQuadrantSegmentedControl) class CanariQuadrantSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {

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
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func sendAction (_ inAction : Selector?, to target : Any?) -> Bool {
    mController?.updateModel (self)
    return super.sendAction (inAction, to:target)
  }

  //····················································································································
  //    binding
  //····················································································································

  private var mController : Controller_CanariQuadrantSegmentedControl_quadrant?

  func bind_quadrant (_ object:EBReadWriteProperty_QuadrantRotation, file:String, line:Int) {
    mController = Controller_CanariQuadrantSegmentedControl_quadrant (object:object, outlet:self)
  }

  func unbind_quadrant () {
    mController?.unregister ()
    mController = nil
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
    super.init (observedObjects:[object], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mObject.prop {
    case .empty :
      mOutlet.enableFromValueBinding (false)
    case .single (let v) :
      mOutlet.enableFromValueBinding (true)
      mOutlet.selectedSegment = v.rawValue
    case .multiple :
      mOutlet.enableFromValueBinding (false)
    }
  }

  //····················································································································

  func updateModel (_ sender : CanariQuadrantSegmentedControl) {
    if let v = QuadrantRotation (rawValue: mOutlet.selectedSegment) {
      _ = mObject.validateAndSetProp (v, windowForSheet:sender.window)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
