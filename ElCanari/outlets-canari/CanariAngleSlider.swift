//
//  CanariAngleSlider.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariAngleSlider
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariAngleSlider : NSSlider, EBUserClassNameProtocol {

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
  //  value binding
  //····················································································································

  fileprivate func update (_ inAngle : EBReadOnlyProperty_Int) {
    switch inAngle.selection {
    case .empty :
      self.enableFromValueBinding (false)
    case .multiple :
      self.enableFromValueBinding (false)
    case .single (let propertyValue) :
      var value = 90.0 - Double (propertyValue) / 1000.0
      if value < 0.0 {
        value += 360.0
      }
      self.doubleValue = value
      self.enableFromValueBinding (true)
    }
  }

  //····················································································································

  private var mController : Controller_CanariAngleSlider_angle? = nil

  //····················································································································

  final func bind_angle (_ object : EBReadWriteProperty_Int) {
    self.mController = Controller_CanariAngleSlider_angle (angle: object, outlet: self)
    self.isContinuous = true
  }

  //····················································································································

  final func unbind_angle () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_CanariAngleSlider_angle
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariAngleSlider_angle : EBObservablePropertyController {

  private var mOutlet : CanariAngleSlider
  private var mAngle  : EBReadWriteProperty_Int

  //····················································································································

  init (angle : EBReadWriteProperty_Int,
        outlet : CanariAngleSlider) {
    mAngle = angle
    mOutlet = outlet
    super.init (observedObjects: [angle], callBack: { outlet.update (angle) } )
  //--- Target
    self.mOutlet.target = self
    self.mOutlet.action = #selector (Controller_CanariAngleSlider_angle.action(_:))
  }

  //····················································································································

  override func unregister () {
    super.unregister ()
    self.mOutlet.target = nil
    self.mOutlet.action = nil
  }

  //····················································································································

  @objc func action (_ sender : CanariAngleSlider) {
    var v = 90.0 - self.mOutlet.doubleValue
    if v < 0.0 {
      v += 360.0
    }
    let angle = Int ((v * 1000.0).rounded (.toNearestOrEven))
    _ = self.mAngle.validateAndSetProp (angle, windowForSheet: sender.window)
    flushOutletEvents ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
