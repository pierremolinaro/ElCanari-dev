//
//  AutoLayoutCanariObservedDimensionField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutCanariObservedDimensionField
//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutCanariObservedDimensionField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    self.delegate = self
    noteObjectAllocation (self)
    self.font = NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
    self.alignment = .center
    self.isEditable = false
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    return NSSize (width: 56.0, height: 19.0)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mController?.unregister ()
    self.mController = nil
    super.ebCleanUp ()
  }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func updateOutlet (dimension : EBReadOnlyProperty_Int, unit : EBReadOnlyProperty_Int) {
    switch combine (dimension.selection, unit: unit.selection) {
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
      self.doubleValue = propertyValue
      self.enableFromValueBinding (true)
    }
  }

  //····················································································································

  private var mController : Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit? = nil

  //····················································································································

  func bind_dimensionAndUnit (_ object : EBReadOnlyProperty_Int,
                              _ unit : EBReadOnlyProperty_Int) -> Self {
    self.mController = Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit (dimension: object, unit: unit, outlet: self)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
//   Controller Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit
//----------------------------------------------------------------------------------------------------------------------

final class Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit : EBReadOnlyPropertyController {

  private var mOutlet: AutoLayoutCanariObservedDimensionField
  private var mDimension : EBReadOnlyProperty_Int
  private var mUnit : EBReadOnlyProperty_Int

  //····················································································································

  init (dimension : EBReadOnlyProperty_Int,
        unit : EBReadOnlyProperty_Int,
        outlet : AutoLayoutCanariObservedDimensionField) {
    self.mDimension = dimension
    self.mUnit = unit
    self.mOutlet = outlet
    super.init (
      observedObjects: [dimension, unit],
      callBack: { outlet.updateOutlet (dimension: dimension, unit: unit) }
    )
  //--- Target
//    self.mOutlet.target = self
//    self.mOutlet.action = #selector(Controller_AutoLayoutCanariObservedDimensionField_dimensionAndUnit.action(_:))
  //--- Number formatter
    let numberFormatter = NumberFormatter ()
    numberFormatter.formatterBehavior = .behavior10_4
    numberFormatter.numberStyle = .decimal
    numberFormatter.localizesFormat = true
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.isLenient = true
    self.mOutlet.formatter = numberFormatter
  }

  //····················································································································

//  override func unregister () {
//    super.unregister ()
//    self.mOutlet.target = nil
//    self.mOutlet.action = nil
//  }

  //····················································································································

//  @objc func action (_ sender : AutoLayoutCanariObservedDimensionField) {
//    switch self.mUnit.selection {
//    case .empty, .multiple :
//      break
//    case .single (let unit) :
//      if let formatter = self.mOutlet.formatter as? NumberFormatter, let outletValueNumber = formatter.number (from: self.mOutlet.stringValue) {
//        let value = Int ((outletValueNumber.doubleValue * Double (unit)).rounded ())
//        _ = self.mDimension.validateAndSetProp (value, windowForSheet: sender.window)
//      }else{
//        __NSBeep ()
//      }
//    }
//  }

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
