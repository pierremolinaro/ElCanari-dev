//——————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutIntField
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutIntField : ALB_NSTextField_enabled_hidden_bindings {

  //································································································

  private let mNumberFormatter = NumberFormatter ()

  //································································································

  private var mInputIsValid = true {
    didSet {
      if self.mInputIsValid != oldValue {
        self.needsDisplay = true
      }
    }
  }


  //································································································

  init (minWidth inWidth : Int, size inSize : EBControlSize) {
    super.init (optionalWidth: inWidth, bold: true, size: inSize.cocoaControlSize)

  //--- Delegate
    self.delegate = self
  //--- Target
    self.target = self
    self.action = #selector (Self.valueDidChangeAction (_:))
  //--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 0
    self.mNumberFormatter.maximumFractionDigits = 0
    self.mNumberFormatter.isLenient = true
    self.formatter = self.mNumberFormatter
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

 //····················································································································

  final func set (min inMin : Int) -> Self {
    self.mNumberFormatter.minimum = NSNumber (value: inMin)
    return self
  }

  //································································································

  final func set (max inMax : Int) -> Self {
    self.mNumberFormatter.maximum = NSNumber (value: inMax)
    return self
  }

  //································································································

  final func set (format inFormatString : String) -> Self {
    self.mNumberFormatter.format = inFormatString
    return self
  }

  //································································································

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
    if let inputString = currentEditor()?.string, let numberFormatter = self.formatter as? NumberFormatter {
      let optionalNumber = numberFormatter.number (from: inputString)
      if let number = optionalNumber, self.isContinuous {
        let value = Int (number.doubleValue.rounded ())
        self.mValueController?.updateModel (withValue: value)
      }
      self.mInputIsValid = optionalNumber != nil
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

  @objc fileprivate func valueDidChangeAction (_ _ : Any?) {
    if let formatter = self.formatter as? NumberFormatter, let outletValueNumber = formatter.number (from: self.stringValue) {
      let value = Int (outletValueNumber.doubleValue.rounded ())
      self.mValueController?.updateModel (withValue: value)
    }else if let v = self.mValueController?.value {
      self.mInputIsValid = true
      self.integerValue = v
    }
  }

  //································································································
  //MARK:  $value binding
  //································································································

  private var mValueController : EBGenericReadWritePropertyController <Int>? = nil

  //································································································

  final func bind_value (_ inObject : EBObservableMutableProperty <Int>, sendContinously : Bool) -> Self {
    self.isContinuous = sendContinously
    self.mValueController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack:  { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //································································································

  private func update (from inObject : EBObservableProperty <Int>) {
    let selection = inObject.selection // TOUJOURS lire la sélection
    if self.currentEditor() == nil {
      self.mInputIsValid = true
      switch selection {
      case .empty :
        self.enable (fromValueBinding: false, self.enabledBindingController)
        self.placeholderString = "No Selection"
        self.stringValue = ""
      case .single (let v) :
        self.enable (fromValueBinding: true, self.enabledBindingController)
        self.placeholderString = nil
        self.intValue = Int32 (v)
      case .multiple :
        self.enable (fromValueBinding: false, self.enabledBindingController)
        self.placeholderString = "Multiple Selection"
        self.stringValue = ""
      }
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
