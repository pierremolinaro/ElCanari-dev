//
//  AutoLayoutTextField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutTextField
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutTextField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate {

  //····················································································································

  init (small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.delegate = self
    self.controlSize = inSmall ? .small : .regular
    self.font = NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
    self.alignment = .center

    self.target = self
    self.action = #selector (AutoLayoutTextField.ebAction(_:))
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

  override var intrinsicContentSize : NSSize {
    return NSSize (width: 56.0, height: 19.0)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mValueController?.unregister ()
    self.mValueController = nil
    super.ebCleanUp ()
  }

  //····················································································································

  func controlTextDidChange (_ inNotification : Notification) {
    if self.mSendContinously {
      self.ebAction (nil)
    }
  }

  //····················································································································

  @objc func ebAction (_ inUnusedSender : Any?) {
    _ = self.mValueController?.updateModel (withCandidateValue: self.stringValue, windowForSheet: self.window)
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
  private var mSendContinously = false

  //····················································································································

  final func bind_value (_ inModel : EBReadWriteProperty_String, sendContinously inContinuous : Bool) -> Self {
    self.mSendContinously = inContinuous
    self.mValueController = EBGenericReadWritePropertyController <String> (
      observedObject: inModel,
      callBack: { [weak self] in self?.updateOutlet (inModel) }
    )
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
