//
//  CanariAngleTextField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   CanariAngleTextField
//----------------------------------------------------------------------------------------------------------------------

class CanariAngleTextField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    self.delegate = self
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    self.delegate = self
    noteObjectAllocation (self)
  }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func updateOutlet (_ object : EBReadOnlyProperty_Int) {
    switch object.selection {
    case .empty :
      self.placeholderString = "No Selection"
      self.stringValue = ""
      self.enableFromValueBinding (false)
    case .multiple :
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
      self.enableFromValueBinding (true)
    case .single (let propertyValue) :
      self.placeholderString = nil
      self.doubleValue = Double (propertyValue) / 1000.0
      self.enableFromValueBinding (true)
    }
  }

  //····················································································································

  private var mController : Controller_CanariAngleTextField_angle? = nil

  //····················································································································

  func bind_angle (_ object:EBReadWriteProperty_Int,
                   file:String, line:Int) {
    self.mController = Controller_CanariAngleTextField_angle (angle: object, outlet: self)
  }

  //····················································································································

  func unbind_angle () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
//   Controller Controller_CanariAngleTextField_angle
//----------------------------------------------------------------------------------------------------------------------

final class Controller_CanariAngleTextField_angle : EBReadOnlyPropertyController {

  private var mOutlet: CanariAngleTextField
  private var mAngle : EBReadWriteProperty_Int
  private var mNumberFormatter : NumberFormatter

  //····················································································································

  init (angle : EBReadWriteProperty_Int,
        outlet : CanariAngleTextField) {
    mAngle = angle
    mOutlet = outlet
    mNumberFormatter = NumberFormatter ()
    super.init (observedObjects: [angle], callBack: { outlet.updateOutlet (angle) } )
  //--- Target
    self.mOutlet.target = self
    self.mOutlet.action = #selector (Controller_CanariAngleTextField_angle.action(_:))
  //--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 3
    self.mNumberFormatter.format = "##0.000°"
    self.mNumberFormatter.isLenient = true
    self.mOutlet.formatter = self.mNumberFormatter
  }

  //····················································································································

  override func unregister () {
    super.unregister ()
    self.mOutlet.target = nil
    self.mOutlet.action = nil
  }

  //····················································································································

  @objc func action (_ sender : CanariAngleTextField) {
    switch self.mAngle.selection {
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

//----------------------------------------------------------------------------------------------------------------------

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

//----------------------------------------------------------------------------------------------------------------------
