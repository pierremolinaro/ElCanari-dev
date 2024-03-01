//——————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariDimensionField
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariDimensionField : AutoLayoutBase_NSTextField {

  //································································································

  fileprivate var mInputIsValid = true {
    didSet {
      if self.mInputIsValid != oldValue {
        self.needsDisplay = true
      }
    }
  }

  //································································································

  init (size inSize : EBControlSize) {
    super.init (optionalWidth: 72, bold: true, size: inSize)
  //--- Target
    self.target = self
    self.action = #selector (Self.valueDidChangeAction (_:))
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
    if let inputString = currentEditor()?.string, let numberFormatter = self.formatter as? NumberFormatter {
      let optionalNumber = numberFormatter.number (from: inputString)
      if optionalNumber != nil, self.isContinuous {
         _ = self.mValueController?.performValidation (inputString)
      }
      self.mInputIsValid = optionalNumber != nil
    }
  }

  //································································································

  @objc fileprivate func valueDidChangeAction (_ _ : Any?) {
    let ok = self.mValueController?.performValidation (self.stringValue) ?? true
    if !ok {
      self.mValueController?.updateOutlet ()
    }
  }

  //································································································

  override func draw (_ inDirtyRect : NSRect) {
    super.draw (inDirtyRect)
    if !self.mInputIsValid {
      NSColor.systemRed.withAlphaComponent (0.25).setFill ()
      NSBezierPath.fill (self.bounds)
    }
  }

  //································································································
  //  value binding
  //································································································

  fileprivate func updateOutlet () {
    self.mValueController?.updateOutlet ()
  }

  //································································································

  private var mValueController : Controller_AutoLayoutCanariDimensionField_dimensionAndUnit? = nil

  //································································································

  final func bind_dimensionAndUnit (_ object : EBObservableMutableProperty <Int>,
                                    _ unit : EBObservableProperty <Int>) -> Self {
    self.mValueController = Controller_AutoLayoutCanariDimensionField_dimensionAndUnit (dimension: object, unit: unit, outlet: self)
    return self
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller Controller_AutoLayoutCanariDimensionField_dimensionAndUnit
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_AutoLayoutCanariDimensionField_dimensionAndUnit : EBObservablePropertyController {

  private weak var mOutlet : AutoLayoutCanariDimensionField? = nil
  private var mDimension : EBObservableMutableProperty <Int>
  private var mUnit : EBObservableProperty <Int>

  //································································································

  init (dimension : EBObservableMutableProperty <Int>,
        unit : EBObservableProperty <Int>,
        outlet inOutlet : AutoLayoutCanariDimensionField) {
    self.mDimension = dimension
    self.mUnit = unit
    self.mOutlet = inOutlet
    super.init (
      observedObjects: [dimension, unit],
      callBack: { [weak inOutlet] in inOutlet?.updateOutlet () }
    )
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

  //································································································

//  override func unregister () {
//    super.unregister ()
//    self.mOutlet.target = nil
//    self.mOutlet.action = nil
//  }

  //································································································

  fileprivate func updateOutlet () {
    if let outlet = self.mOutlet {
      outlet.mInputIsValid = true
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

  //································································································

  fileprivate func performValidation (_ inOptionalInputString : String?) -> Bool {
    switch self.mUnit.selection {
    case .empty, .multiple :
      return false
    case .single (let unit) :
      if let formatter = self.mOutlet?.formatter as? NumberFormatter,
         let inInputString = inOptionalInputString,
         let outletValueNumber = formatter.number (from: inInputString) {
        let value = Int ((outletValueNumber.doubleValue * Double (unit)).rounded ())
        self.mDimension.setProp (value)
        return true
      }else{
        return false
      }
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————
