//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariDimensionField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariDimensionField : AutoLayoutBaseTextField, NSTextFieldDelegate {

  //····················································································································

//  init (width inWidth : Int, size inSize : EBControlSize) {
//    super.init (frame: NSRect ())
//    noteObjectAllocation (self)
//    self.translatesAutoresizingMaskIntoConstraints = false
//
//    self.setContentCompressionResistancePriority (.required, for: .vertical)
//
//    self.controlSize = inSize.cocoaControlSize
//    self.font = NSFont.boldSystemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
//    self.alignment = .center
//  }

  //····················································································································

//  required init? (coder inCoder : NSCoder) {
//    fatalError ("init(coder:) has not been implemented")
//  }

  //····················································································································

//  deinit {
//    noteObjectDeallocation (self)
//  }
  
  //····················································································································
  //  By Default, super.intrinsicContentSize.width is -1, meaning the text field is invisible
  //  So we need to define intrinsicContentSize.width explicitly
  //  super.intrinsicContentSize.height is valid (19.0 for small size, 22.0 for regular size, ...)-
  //····················································································································

//  override var intrinsicContentSize : NSSize {
//    let s = super.intrinsicContentSize
//    return NSSize (width: 64.0, height: s.height)
//  }

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

  override func ebCleanUp () {
    self.mController?.unregister ()
    self.mController = nil
    super.ebCleanUp ()
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

  private var mOutlet: AutoLayoutCanariDimensionField
  private var mDimension : EBReadWriteProperty_Int
  private var mUnit : EBReadOnlyProperty_Int

  //····················································································································

  init (dimension : EBReadWriteProperty_Int,
        unit : EBReadOnlyProperty_Int,
        outlet : AutoLayoutCanariDimensionField) {
    self.mDimension = dimension
    self.mUnit = unit
    self.mOutlet = outlet
    super.init (
      observedObjects: [dimension, unit],
      callBack: { outlet.updateOutlet () }
    )
  //--- Target
    self.mOutlet.target = self
    self.mOutlet.action = #selector (Self.textFieldAction(_:))
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

  override func unregister () {
    super.unregister ()
    self.mOutlet.target = nil
    self.mOutlet.action = nil
  }

  //····················································································································

  fileprivate func updateOutlet () {
    switch combine (self.mDimension.selection, unit: self.mUnit.selection) {
    case .empty :
      self.mOutlet.placeholderString = "No Selection"
      self.mOutlet.stringValue = ""
      self.mOutlet.enable (fromValueBinding: false)
    case .multiple :
      self.mOutlet.placeholderString = "Multiple Selection"
      self.mOutlet.stringValue = ""
      self.mOutlet.enable (fromValueBinding: true)
    case .single (let propertyValue) :
      self.mOutlet.placeholderString = nil
      self.mOutlet.doubleValue = propertyValue
      self.mOutlet.enable (fromValueBinding: true)
    }
  }

  //····················································································································

  fileprivate func performValidation (_ inSender : AutoLayoutCanariDimensionField) -> Bool {
    switch self.mUnit.selection {
    case .empty, .multiple :
      return false
    case .single (let unit) :
      if let formatter = self.mOutlet.formatter as? NumberFormatter, let outletValueNumber = formatter.number (from: self.mOutlet.stringValue) {
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
