//
//  AutoLayoutTextField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutTextField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutTextField : AutoLayoutBase_NSTextField {

  //····················································································································
  //  User information
  //····················································································································

  var mTextFieldUserInfo : Any? = nil // Not used, freely available for user

  //····················································································································

  init (minWidth inWidth : Int, size inSize : EBControlSize) {
    super.init (optionalWidth: inWidth, bold: true, size: inSize)

    self.setContentCompressionResistancePriority (.required, for: .vertical)

    self.alignment = .center

    self.target = self
    self.action = #selector (Self.ebAction(_:))
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  var mTextDidChange : Optional < () -> Void>  = nil {
    didSet {
      self.mTextDidChange? ()
    }
  }

  //····················································································································

  @objc func ebAction (_ inUnusedSender : Any?) {
    _ = self.mValueController?.updateModel (withCandidateValue: self.stringValue, windowForSheet: self.window)
  }

  //····················································································································

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
    self.mTextDidChange? ()
    if self.isContinuous {
      self.ebAction (nil)
    }
  }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func updateOutlet (_ inModel : EBReadOnlyProperty_String) {
    switch inModel.selection {
    case .empty :
      self.placeholderString = "No Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: false, self.enabledBindingController)
    case .multiple :
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: true, self.enabledBindingController)
    case .single (let propertyValue) :
      self.placeholderString = nil
      self.stringValue = propertyValue
      self.enable (fromValueBinding: true, self.enabledBindingController)
    }
    self.invalidateIntrinsicContentSize ()
  }

  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <String>? = nil

  //····················································································································

  final func bind_value (_ inModel : EBReadWriteProperty_String, sendContinously inContinuous : Bool) -> Self {
    self.isContinuous = inContinuous
    self.mValueController = EBGenericReadWritePropertyController <String> (
      observedObject: inModel,
      callBack: { [weak self] in self?.updateOutlet (inModel) }
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————