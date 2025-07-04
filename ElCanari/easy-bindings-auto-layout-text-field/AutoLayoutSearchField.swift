//
//  AutoLayoutSearchField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/10/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   AutoLayoutSearchField
//--------------------------------------------------------------------------------------------------

final class AutoLayoutSearchField : NSSearchField, @MainActor NSSearchFieldDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mWidth : CGFloat
  private var mDelegate : Optional < (String) -> Void > = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (width inWidth : Int, size inSize : EBControlSize) {
    self.mWidth = CGFloat (inWidth)
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.delegate = self
    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    self.alignment = .left

    self.target = self
    self.action = #selector (Self.ebAction(_:))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setRecentsAutosaveName (_ inName : String) -> Self {
    self.recentsAutosaveName = inName
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  By Default, super.intrinsicContentSize.width is -1, meaning the text field is invisible
  //  So we need to define intrinsicContentSize.width explicitly
  //  super.intrinsicContentSize.height is valid (19.0 for small size, 22.0 for regular size, ...)-
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    let s = super.intrinsicContentSize
    return NSSize (width: self.mWidth, height: s.height)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setDelegate (_ inDelegate : @escaping (String) -> Void) {
    self.mDelegate = inDelegate
    inDelegate (self.stringValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func ebAction (_ _ : Any?) {
    self.mValueController?.updateModel (withValue: self.stringValue)
    self.mDelegate? (self.stringValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // IMPLEMENTATION OF NSTextFieldDelegate
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func controlTextDidChange (_ inNotification : Notification) {
    if self.mSendContinously {
      self.ebAction (nil)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $enabled binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  var mEnabledBindingController : EnabledBindingController? = nil
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
//    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
//    return self
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  value binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func updateOutlet (_ inModel : EBObservableProperty <String>) {
    switch inModel.selection {
    case .empty :
      self.placeholderString = "No Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .multiple :
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    case .single (let propertyValue) :
      self.placeholderString = nil
      self.stringValue = propertyValue
      self.mDelegate? (propertyValue)
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mValueController : EBGenericReadWritePropertyController <String>? = nil
  private var mSendContinously = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_value (_ inModel : EBObservableMutableProperty <String>, sendContinously inContinuous : Bool) -> Self {
    self.mSendContinously = inContinuous
    self.mValueController = EBGenericReadWritePropertyController <String> (
      observedObject: inModel,
      callBack: { [weak self] in self?.updateOutlet (inModel) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Closure action
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final private var mClosureAction : Optional < () -> Void > = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setClosureAction (_ inClosureAction : @escaping () -> Void) -> Self {
    self.mClosureAction = inClosureAction
    self.target = self
    self.action = #selector (Self.runClosureAction (_:))
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   @objc private final func runClosureAction (_ _ : Any?) {
     self.mClosureAction? ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
