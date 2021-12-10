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

final class AutoLayoutTextField : NSTextField, EBUserClassNameProtocol {

  private let mWidth : CGFloat
  var mTextDidChange : Optional < () -> Void>  = nil

  //····················································································································
  //  User information
  //····················································································································

  var mTextFieldUserInfo : Any? = nil // Not used, freely available for user

  //····················································································································

  init (width inWidth : Int, size inSize : EBControlSize) {
    self.mWidth = CGFloat (inWidth)
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.boldSystemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    self.alignment = .center

    self.target = self
    self.action = #selector (Self.ebAction(_:))
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  final func set (alignment inAlignment : TextAlignment) -> Self {
    self.alignment = inAlignment.cocoaAlignment
    return self
  }

  //····················································································································

  func multiLine () -> Self {
    self.usesSingleLineMode = false
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)
    return self
  }

  //····················································································································
  //  By Default, super.intrinsicContentSize.width is -1, meaning the text field is invisible
  //  So we need to define intrinsicContentSize.width explicitly
  //  super.intrinsicContentSize.height is valid (19.0 for small size, 22.0 for regular size, ...)-
  //····················································································································

  override var intrinsicContentSize : NSSize {
    let s = super.intrinsicContentSize
    return NSSize (width: self.mWidth, height: s.height)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mValueController?.unregister ()
    self.mValueController = nil
    super.ebCleanUp ()
  }

  //····················································································································

  @objc func ebAction (_ inUnusedSender : Any?) {
    self.mTextDidChange? ()
    _ = self.mValueController?.updateModel (withCandidateValue: self.stringValue, windowForSheet: self.window)
  }

  //····················································································································

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
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
      self.enable (fromValueBinding: false)
    case .multiple :
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: true)
    case .single (let propertyValue) :
      self.placeholderString = nil
      self.stringValue = propertyValue
      self.enable (fromValueBinding: true)
    }
  }

  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <String>? = nil
//  private var mSendContinously = false

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
