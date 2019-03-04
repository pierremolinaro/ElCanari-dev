//
//  CanariPackageArcAngleTextField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariPackageArcAngleTextField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariPackageArcAngleTextField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    self.delegate = self
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    self.delegate = self
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  value binding
  //····················································································································

  private var mController : Controller_CanariPackageArcAngleTextField_angle?

  //····················································································································

  func bind_angle (_ object:EBReadWriteProperty_Int,
                   file:String, line:Int) {
    self.mController = Controller_CanariPackageArcAngleTextField_angle (angle: object, outlet: self)
  }

  //····················································································································

  func unbind_angle () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_CanariPackageArcAngleTextField_angle
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariPackageArcAngleTextField_angle : EBSimpleController {

  private var mOutlet: CanariPackageArcAngleTextField
  private var mAngle : EBReadWriteProperty_Int
  private var mNumberFormatter : NumberFormatter

  //····················································································································

  init (angle: EBReadWriteProperty_Int,
        outlet: CanariPackageArcAngleTextField) {
    mAngle = angle
    mOutlet = outlet
    mNumberFormatter = NumberFormatter ()
    super.init (observedObjects: [angle])
  //--- Target
    mOutlet.target = self
    mOutlet.action = #selector (Controller_CanariPackageArcAngleTextField_angle.action(_:))
  //--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 3
    self.mNumberFormatter.format = "##0.000°"
    self.mNumberFormatter.isLenient = true
    self.mOutlet.formatter = self.mNumberFormatter
  //--- Call back
    self.mEventCallBack = { [weak self] in self?.updateOutlet () }
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
      self.mOutlet.stringValue = "—"
      self.mOutlet.enableFromValueBinding (false)
    case .multiple :
      self.mOutlet.stringValue = "multiple"
      self.mOutlet.enableFromValueBinding (true)
    case .single (let propertyValue) :
      self.mOutlet.doubleValue = Double (propertyValue) / 1000.0
      self.mOutlet.enableFromValueBinding (true)
    }
  }

  //····················································································································

  @objc func action (_ sender : CanariPackageArcAngleTextField) {
    switch self.mAngle.prop {
    case .empty, .multiple :
      break
    case .single (_) :
      if let outletValueNumber = self.mNumberFormatter.number (from: self.mOutlet.stringValue) {
        let value : Int = Int (round (outletValueNumber.doubleValue * 1000.0))
        _ = self.mAngle.validateAndSetProp (value, windowForSheet: sender.window)
      }else{
        __NSBeep ()
      }
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
