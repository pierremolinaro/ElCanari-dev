//
//  AutoLayoutBase-NSTextField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutBase_NSTextField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBase_NSTextField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  private let mWidth : CGFloat?

  //····················································································································

  init (optionalWidth inOptionalWidth : Int?, bold inBold : Bool, size inSize : EBControlSize) {
    if let w = inOptionalWidth {
      self.mWidth = CGFloat (w)
    }else{
      self.mWidth = nil
    }
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentCompressionResistancePriority (.required, for: .vertical)

    self.controlSize = inSize.cocoaControlSize
    let size = NSFont.systemFontSize (for: self.controlSize)
    self.font = inBold ? NSFont.boldSystemFont (ofSize:size) : NSFont.systemFont (ofSize: size)
    self.alignment = .center
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

  final override var acceptsFirstResponder: Bool { return true }

  //····················································································································

  final func set (alignment inAlignment : TextAlignment) -> Self {
    self.alignment = inAlignment.cocoaAlignment
    return self
  }

  //····················································································································

  final func multiLine () -> Self {
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
    var s = super.intrinsicContentSize
    if let w = self.mWidth {
      s.width = w
    }
    return s
  }

  //····················································································································
  //  $enabled binding
  //····················································································································

  private var mEnabledBindingController : EnabledBindingController? = nil
  var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  //····················································································································

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  //····················································································································
  //  $hidden binding
  //····················································································································

  private var mHiddenBindingController : HiddenBindingController? = nil
  var hiddenBindingController : HiddenBindingController? { return self.mHiddenBindingController }

  //····················································································································

  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mHiddenBindingController = HiddenBindingController (inExpression, self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
