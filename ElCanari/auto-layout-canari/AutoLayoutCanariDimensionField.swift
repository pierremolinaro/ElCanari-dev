//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariDimensionField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariDimensionField : AutoLayoutBase_NSTextField, NSTextFieldDelegate {

  //····················································································································

  init (minWidth inWidth : Int, size inSize : EBControlSize) {
    super.init (optionalWidth: inWidth, bold: true, size: inSize)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func resignFirstResponder () -> Bool {
    // Swift.print ("resignFirstResponder")
    if let controller = self.mController {
      let ok = controller.performValidation (self)
      return ok
    }else{
      return super.resignFirstResponder ()
    }
  }

  //····················································································································

  override func textShouldEndEditing (_ inTextObject : NSText) -> Bool {
    // Swift.print ("textShouldEndEditing")
    if let controller = self.mController {
      let ok = controller.performValidation (self)
      if !ok {
        controller.updateOutlet () // Restore previous valid value
      }
      return ok
    }else{
      return super.textShouldEndEditing (inTextObject)
    }
  }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func updateOutlet () {
    self.mController?.updateOutlet ()
  }

  //····················································································································

  private var mController : Controller_AutoLayoutCanariDimensionField_dimensionAndUnit? = nil

  //····················································································································

  final func bind_dimensionAndUnit (_ object : EBReadWriteProperty_Int,
                                    _ unit : EBReadOnlyProperty_Int) -> Self {
    self.mController = Controller_AutoLayoutCanariDimensionField_dimensionAndUnit (dimension: object, unit: unit, outlet: self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_AutoLayoutCanariDimensionField_dimensionAndUnit
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_AutoLayoutCanariDimensionField_dimensionAndUnit : EBObservablePropertyController {

  private weak var mOutlet : AutoLayoutCanariDimensionField? = nil
  private var mDimension : EBReadWriteProperty_Int
  private var mUnit : EBReadOnlyProperty_Int

  //····················································································································

  init (dimension : EBReadWriteProperty_Int,
        unit : EBReadOnlyProperty_Int,
        outlet inOutlet : AutoLayoutCanariDimensionField) {
    self.mDimension = dimension
    self.mUnit = unit
    self.mOutlet = inOutlet
    super.init (
      observedObjects: [dimension, unit],
      callBack: { [weak inOutlet] in inOutlet?.updateOutlet () }
    )
  //--- Target
    inOutlet.target = self
    inOutlet.action = #selector (Self.textFieldAction(_:))
  //--- Number formatter
    let numberFormatter = NumberFormatter ()
    numberFormatter.formatterBehavior = .behavior10_4
    numberFormatter.numberStyle = .decimal
    numberFormatter.localizesFormat = true
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.isLenient = true
    inOutlet.formatter = numberFormatter
  }

  //····················································································································

//  override func unregister () {
//    super.unregister ()
//    self.mOutlet.target = nil
//    self.mOutlet.action = nil
//  }

  //····················································································································

  fileprivate func updateOutlet () {
    if let outlet = self.mOutlet {
      switch combine (self.mDimension.selection, unit: self.mUnit.selection) {
      case .empty :
        outlet.placeholderString = "No Selection"
        outlet.stringValue = ""
        outlet.enable (fromValueBinding: false, outlet.enabledBindingController)
      case .multiple :
        outlet.placeholderString = "Multiple Selection"
        outlet.stringValue = ""
        outlet.enable (fromValueBinding: true, outlet.enabledBindingController)
      case .single (let propertyValue) :
        outlet.placeholderString = nil
        outlet.doubleValue = propertyValue
        outlet.enable (fromValueBinding: true, outlet.enabledBindingController)
      }
    }
  }

  //····················································································································

  fileprivate func performValidation (_ inSender : AutoLayoutCanariDimensionField) -> Bool {
    switch self.mUnit.selection {
    case .empty, .multiple :
      return false
    case .single (let unit) :
      if let formatter = self.mOutlet?.formatter as? NumberFormatter,
         let stringValue = self.mOutlet?.stringValue,
         let outletValueNumber = formatter.number (from: stringValue) {
        let value = Int ((outletValueNumber.doubleValue * Double (unit)).rounded ())
        return self.mDimension.validateAndSetProp (value, windowForSheet: inSender.window)
      }else{
        NSSound.beep ()
        return false
      }
    }
  }

  //····················································································································

  @objc func textFieldAction (_ inSender : AutoLayoutCanariDimensionField) {
    _ = self.performValidation (inSender)
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
