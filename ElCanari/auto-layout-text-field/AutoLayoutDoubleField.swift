//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutDoubleField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutDoubleField : AutoLayoutBase_NSTextField {

  //····················································································································

  private let mNumberFormatter = NumberFormatter ()

  //····················································································································

  private var mInputIsValid = true {
    didSet {
      if self.mInputIsValid != oldValue {
        self.needsDisplay = true
      }
    }
  }

  //····················································································································

  init (minWidth inWidth : Int, size inSize : EBControlSize) {
    super.init (optionalWidth: inWidth, bold: true, size: inSize)
  //--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 2
    self.mNumberFormatter.maximumFractionDigits = 2
    self.mNumberFormatter.isLenient = true
    self.formatter = self.mNumberFormatter
  //--- Target
    self.target = self
    self.action = #selector (Self.valueDidChangeAction (_:))
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func set (min inMin : Int) -> Self {
    self.mNumberFormatter.minimum = NSNumber (value: inMin)
    return self
  }

  //····················································································································

  final func set (max inMax : Int) -> Self {
    self.mNumberFormatter.maximum = NSNumber (value: inMax)
    return self
  }

  //····················································································································

  final func set (format inFormatString : String) -> Self {
    self.mNumberFormatter.format = inFormatString
    return self
  }

  //····················································································································

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
    if let inputString = currentEditor()?.string, let numberFormatter = self.formatter as? NumberFormatter {
      let optionalNumber = numberFormatter.number (from: inputString)
      if let number = optionalNumber, self.isContinuous {
        let value = number.doubleValue
        _ = self.mValueController?.updateModel (withCandidateValue: value, windowForSheet: self.window)
      }
      self.mInputIsValid = optionalNumber != nil
    }
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    super.draw (inDirtyRect)
    if !self.mInputIsValid {
      NSColor.systemRed.withAlphaComponent (0.25).setFill ()
      NSBezierPath.fill (self.bounds)
    }
  }

  //····················································································································

  @objc fileprivate func valueDidChangeAction (_ inSender : AutoLayoutDoubleField) {
    if let formatter = self.formatter as? NumberFormatter,
       let outletValueNumber = formatter.number (from: self.stringValue) {
      let value = outletValueNumber.doubleValue
      _ = self.mValueController?.updateModel (withCandidateValue: value, windowForSheet: self.window)
    }else if let v = self.mValueController?.value {
      self.mInputIsValid = true
      self.doubleValue = v
    }
  }

  //····················································································································
  //MARK:  $value binding
  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <Double>? = nil

  //····················································································································

  final func bind_value (_ inObject : EBReadWriteProperty_Double, sendContinously : Bool) -> Self {
    self.isContinuous = sendContinously
    self.mValueController = EBGenericReadWritePropertyController <Double> (
      observedObject: inObject,
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBReadWriteProperty_Double) {
    if self.currentEditor() == nil {
      self.mInputIsValid = true
      switch model.selection {
      case .empty :
        self.enable (fromValueBinding: false, self.enabledBindingController)
        self.placeholderString = "No Selection"
        self.stringValue = ""
      case .single (let v) :
        self.enable (fromValueBinding: true, self.enabledBindingController)
        self.placeholderString = nil
        self.doubleValue = CGFloat (v)
      case .multiple :
        self.enable (fromValueBinding: true, self.enabledBindingController)
        self.placeholderString = "Multiple Selection"
        self.stringValue = ""
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
