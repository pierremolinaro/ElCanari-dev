//
//  CanariPackageArcAngleSlider.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariPackageArcAngleSlider
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariPackageArcAngleSlider : NSSlider, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  value binding
  //····················································································································

  private var mController : Controller_CanariPackageArcAngleSlider_angle?

  //····················································································································

  func bind_angle (_ object:EBReadWriteProperty_Int,
                   file:String, line:Int) {
    self.mController = Controller_CanariPackageArcAngleSlider_angle (angle: object, outlet: self)
  }

  //····················································································································

  func unbind_angle () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_CanariPackageArcAngleSlider_angle
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariPackageArcAngleSlider_angle : EBSimpleController {

  private var mOutlet: CanariPackageArcAngleSlider
  private var mAngle : EBReadWriteProperty_Int

  //····················································································································

  init (angle: EBReadWriteProperty_Int,
        outlet: CanariPackageArcAngleSlider) {
    mAngle = angle
    mOutlet = outlet
    super.init (observedObjects: [angle])
  //--- Target
    mOutlet.target = self
    mOutlet.action = #selector (Controller_CanariPackageArcAngleSlider_angle.action(_:))
  //--- Call back
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  override func unregister () {
    super.unregister ()
    self.mOutlet.target = nil
    self.mOutlet.action = nil
  }

  //····················································································································

  private func updateOutlet () {
    switch self.mAngle.prop {
    case .empty :
      self.mOutlet.enableFromValueBinding (false)
    case .multiple :
      self.mOutlet.enableFromValueBinding (false)
    case .single (let propertyValue) :
      var value = Double (propertyValue) / 1000.0 - 90.0
      if value < 0.0 {
        value += 360.0
      }
      self.mOutlet.doubleValue = value
      self.mOutlet.enableFromValueBinding (true)
    }
  }

  //····················································································································

  @objc func action (_ sender : CanariPackageArcAngleSlider) {
    switch self.mAngle.prop {
    case .empty, .multiple :
      break
    case .single (_) :
      var v = self.mOutlet.doubleValue + 90.0
      if v >= 360.0 {
        v -= 360.0
      }
      let angle : Int = Int (round (v * 1000.0))
      _ = self.mAngle.validateAndSetProp (angle, windowForSheet: sender.window)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func combine (_ dimension : EBSelection <Int>, unit : EBSelection <Int>) -> EBSelection <Double> {
  switch dimension {
  case .empty :
    return .empty
  case .multiple :
    switch dimension {
    case .empty :
      return .empty
    case .multiple, .single :
      return .multiple
    }
  case .single (let dimensionValue) :
    switch unit {
    case .empty :
      return .empty
    case .multiple :
      return .multiple
    case .single (let unitValue):
      return .single (Double (dimensionValue) / Double (unitValue))
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
