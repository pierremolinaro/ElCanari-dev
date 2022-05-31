//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutIntField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutIntField : AutoLayoutBase_NSTextField {

  //····················································································································

  private let mNumberFormatter = NumberFormatter ()

  //····················································································································

  init (minWidth inWidth : Int, size inSize : EBControlSize) {
    super.init (optionalWidth: inWidth, bold: true, size: inSize)

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
  //  self.mTextDidChange? ()
    if self.isContinuous {
      self.valueDidChangeAction (nil)
    }
//    if self.isContinuous {
//      NSSound.beep ()
//      if let inputString = currentEditor()?.string {
//        // NSLog ("inputString %@", inputString)
//        let numberFormatter = self.formatter as! NumberFormatter
//        let number = numberFormatter.number (from: inputString)
//        if number == nil {
//          _ = control (
//            self,
//            didFailToFormatString: inputString,
//            errorDescription: "The “\(inputString)” value is invalid."
//          )
//        }else{
//          NSApp.sendAction (self.action!, to: self.target, from: self)
//        }
//      }
//    }
  }

  //····················································································································
  //    NSTextFieldDelegate delegate function
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
 //         self.integerValue = self.myIntegerValue.0
          }
        }
      )
    }
    return false
  }

  //····················································································································

  @objc fileprivate func valueDidChangeAction (_ inSender : Any?) {
    if let formatter = self.formatter as? NumberFormatter, let outletValueNumber = formatter.number (from: self.stringValue) {
      let value = Int (outletValueNumber.doubleValue.rounded ())
      _ = self.mValueController?.updateModel (withCandidateValue: value, windowForSheet: self.window)
    }
  }

  //····················································································································
  //MARK:  $value binding
  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  final func bind_value (_ inObject : EBReadWriteProperty_Int, sendContinously : Bool) -> Self {
    self.isContinuous = sendContinously
    self.mValueController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack:  { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_Int) {
    switch model.selection {
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

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
