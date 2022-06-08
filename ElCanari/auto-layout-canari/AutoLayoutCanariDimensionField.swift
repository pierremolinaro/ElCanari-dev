//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariDimensionField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariDimensionField : AutoLayoutBase_NSTextField {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (optionalWidth: 72, bold: true, size: inSize)
  //--- Target
    self.target = self
    self.action = #selector (Self.valueDidChangeAction (_:))
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
    if self.isContinuous {
      if let inputString = currentEditor()?.string,
         let numberFormatter = self.formatter as? NumberFormatter {
        let number = numberFormatter.number (from: inputString)
        if number == nil {
          _ = control (
            self,
            didFailToFormatString: inputString,
            errorDescription: "The “\(inputString)” value is invalid."
          )
        }else{
          NSApp.sendAction (self.action!, to: self.target, from: self)
        }
      }
    }
  }

  //····················································································································
  //MARK:    NSTextFieldDelegate delegate function
  //····················································································································

  func control (_ control : NSControl,
                didFailToFormatString string : String,
                errorDescription error : String?) -> Bool {
    let alert = NSAlert ()
    if let window = control.window {
      alert.messageText = error!
      alert.informativeText = "Please provide a valid value."
      alert.addButton (withTitle: "Ok")
      alert.addButton (withTitle: "Discard Change")
      alert.beginSheetModal (
        for: window,
        completionHandler: { (response : NSApplication.ModalResponse) -> Void in
          if response == .alertSecondButtonReturn { // Discard Change
            _ = self.mValueController?.updateOutlet ()
          }
        }
      )
    }
    return false
  }

  //····················································································································

  @objc fileprivate func valueDidChangeAction (_ inSender : Any?) {
    _ = self.mValueController?.performValidation ()
  }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func updateOutlet () {
    self.mValueController?.updateOutlet ()
  }

  //····················································································································

  private var mValueController : Controller_AutoLayoutCanariDimensionField_dimensionAndUnit? = nil

  //····················································································································

  final func bind_dimensionAndUnit (_ object : EBReadWriteProperty_Int,
                                    _ unit : EBReadOnlyProperty_Int) -> Self {
    self.mValueController = Controller_AutoLayoutCanariDimensionField_dimensionAndUnit (dimension: object, unit: unit, outlet: self)
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
  //--- Target, action
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

  fileprivate func performValidation () -> Bool {
    switch self.mUnit.selection {
    case .empty, .multiple :
      return false
    case .single (let unit) :
      if let formatter = self.mOutlet?.formatter as? NumberFormatter,
         let inInputString = self.mOutlet?.stringValue,
         let outletValueNumber = formatter.number (from: inInputString) {
        let value = Int ((outletValueNumber.doubleValue * Double (unit)).rounded ())
        return self.mDimension.validateAndSetProp (value, windowForSheet: self.mOutlet?.window)
      }else{
        self.updateOutlet ()
        NSSound.beep ()
        return false
      }
    }
  }

  //····················································································································

  @objc func textFieldAction (_ inSender : AutoLayoutCanariDimensionField) {
    _ = self.performValidation ()
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
